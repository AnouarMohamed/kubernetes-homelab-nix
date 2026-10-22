#!/usr/bin/env python3
"""Fail-closed structural and supply-chain checks for the rendered cluster."""

from __future__ import annotations

import argparse
import collections
import pathlib
import re
import sys
from typing import Any

import yaml


class KubernetesLoader(yaml.CSafeLoader):
    """Keep YAML 1.1's `value` key from being resolved as a Python object key."""


KubernetesLoader.add_constructor(
    "tag:yaml.org,2002:value",
    lambda loader, node: loader.construct_scalar(node),
)

NATIVE_API_GROUPS = {
    "",
    "admissionregistration.k8s.io",
    "apiextensions.k8s.io",
    "apps",
    "authentication.k8s.io",
    "authorization.k8s.io",
    "autoscaling",
    "batch",
    "certificates.k8s.io",
    "coordination.k8s.io",
    "discovery.k8s.io",
    "events.k8s.io",
    "flowcontrol.apiserver.k8s.io",
    "networking.k8s.io",
    "node.k8s.io",
    "policy",
    "rbac.authorization.k8s.io",
    "resource.k8s.io",
    "scheduling.k8s.io",
    "storage.k8s.io",
}

CLUSTER_SCOPED_BUILTINS = {
    "APIService",
    "CSIDriver",
    "CSINode",
    "ClusterRole",
    "ClusterRoleBinding",
    "CustomResourceDefinition",
    "GatewayClass",
    "MutatingWebhookConfiguration",
    "Namespace",
    "Node",
    "PersistentVolume",
    "PriorityClass",
    "RuntimeClass",
    "StorageClass",
    "ValidatingAdmissionPolicy",
    "ValidatingAdmissionPolicyBinding",
    "ValidatingWebhookConfiguration",
    "VolumeAttachment",
    "VolumeSnapshotClass",
}

IMAGE_REFERENCE = re.compile(
    r"^(?:docker\.io|ecr-public\.aws\.com|ghcr\.io|quay\.io|registry\.k8s\.io)/"
)


def load_documents(path: pathlib.Path) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as handle:
        return [
            document
            for document in yaml.load_all(handle, Loader=KubernetesLoader)
            if isinstance(document, dict) and document
        ]


def walk_strings(value: Any):
    if isinstance(value, dict):
        for child in value.values():
            yield from walk_strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_strings(child)
    elif isinstance(value, str):
        yield value


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=pathlib.Path)
    parser.add_argument("--repository-root", type=pathlib.Path, required=True)
    parser.add_argument("--kubernetes-minor", required=True)
    arguments = parser.parse_args()

    documents = load_documents(arguments.manifest)
    errors: list[str] = []
    served_custom_resources: set[tuple[str, str]] = set()
    custom_resource_scopes: dict[tuple[str, str], str] = {}

    for index, document in enumerate(documents, start=1):
        missing = [field for field in ("apiVersion", "kind", "metadata") if field not in document]
        if missing:
            errors.append(f"document {index}: missing {', '.join(missing)}")
            continue
        metadata = document.get("metadata") or {}
        if not metadata.get("name"):
            errors.append(f"document {index}: metadata.name is required")
        if document.get("kind") != "CustomResourceDefinition":
            continue
        spec = document.get("spec") or {}
        group = spec.get("group")
        kind = (spec.get("names") or {}).get("kind")
        scope = spec.get("scope")
        if group and kind and scope:
            custom_resource_scopes[(group, kind)] = scope
            for version in spec.get("versions") or []:
                if version.get("served"):
                    served_custom_resources.add((f"{group}/{version.get('name')}", kind))

    identities: dict[tuple[str, str, str, str], list[int]] = collections.defaultdict(list)
    applications: list[dict[str, Any]] = []

    for index, document in enumerate(documents, start=1):
        api_version = str(document.get("apiVersion", ""))
        kind = str(document.get("kind", ""))
        metadata = document.get("metadata") or {}
        name = str(metadata.get("name", ""))
        namespace = str(metadata.get("namespace", ""))
        group = api_version.split("/", 1)[0] if "/" in api_version else ""
        identity = (api_version, kind, namespace, name)
        identities[identity].append(index)

        custom_scope = custom_resource_scopes.get((group, kind))
        cluster_scoped = kind in CLUSTER_SCOPED_BUILTINS or custom_scope == "Cluster"
        if not cluster_scoped and not namespace:
            errors.append(f"document {index}: namespaced resource {api_version}/{kind}/{name} has no namespace")

        if (
            group not in NATIVE_API_GROUPS
            and kind != "CustomResourceDefinition"
            and (api_version, kind) not in served_custom_resources
        ):
            errors.append(f"document {index}: no served CRD for {api_version}/{kind}/{name}")

        if kind.lower() in {"ksops", "kustomization"}:
            errors.append(f"document {index}: build-time {kind} object leaked into cluster output")

        if api_version == "cert-manager.io/v1alpha2":
            errors.append(f"document {index}: deprecated cert-manager.io/v1alpha2 API")

        labels = metadata.get("labels") or {}
        for label in (
            "pod-security.kubernetes.io/enforce-version",
            "pod-security.kubernetes.io/audit-version",
            "pod-security.kubernetes.io/warn-version",
        ):
            if label in labels and labels[label] != f"v{arguments.kubernetes_minor}":
                errors.append(
                    f"document {index}: {label}={labels[label]} does not match v{arguments.kubernetes_minor}"
                )

        for value in walk_strings(document):
            if IMAGE_REFERENCE.match(value) and ":" in value and "@sha256:" not in value:
                errors.append(f"document {index}: mutable image reference {value}")

        if kind == "Application":
            applications.append(document)

    for identity, indexes in identities.items():
        if len(indexes) > 1:
            errors.append(f"duplicate resource {identity!r} in documents {indexes}")

    if len(applications) != 1:
        errors.append(f"expected exactly one Argo CD Application, found {len(applications)}")
    else:
        source = (applications[0].get("spec") or {}).get("source") or {}
        source_path = source.get("path")
        if not source_path or not (arguments.repository_root / source_path).is_dir():
            errors.append(f"Argo CD source path does not exist: {source_path!r}")
        if source.get("targetRevision") != "main":
            errors.append("Argo CD targetRevision must be the protected main branch")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        print(f"manifest integrity failed with {len(errors)} error(s)", file=sys.stderr)
        return 1

    crd_count = sum(document.get("kind") == "CustomResourceDefinition" for document in documents)
    print(
        f"manifest integrity passed: {len(documents)} resources, "
        f"{crd_count} CRDs, {len(served_custom_resources)} served custom APIs"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
