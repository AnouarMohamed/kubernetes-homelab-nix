#!/usr/bin/env python3
"""Aggregate Kubernetes YAML documents into a readable Nix list."""

from __future__ import annotations

import argparse
from pathlib import Path

import yaml

from convert_yaml_to_nix import render


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("destination", type=Path)
    parser.add_argument("sources", nargs="+", type=Path)
    args = parser.parse_args()

    objects: list[object] = []
    used: list[str] = []
    for source in args.sources:
        files = sorted(source.rglob("*.yaml")) if source.is_dir() else [source]
        for path in files:
            if path.name.endswith(".sops.yaml"):
                continue
            for document in yaml.safe_load_all(path.read_text()):
                if not document:
                    continue
                if document.get("apiVersion", "").startswith("kustomize.config.k8s.io/"):
                    continue
                if "apiVersion" not in document or "kind" not in document:
                    continue
                objects.append(document)
                used.append(str(path))

    args.destination.parent.mkdir(parents=True, exist_ok=True)
    header = "# One-time conversion from:\n" + "".join(f"# - {path}\n" for path in used)
    args.destination.write_text(header + render(objects) + "\n")


if __name__ == "__main__":
    main()

