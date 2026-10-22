#!/usr/bin/env bash
set -euo pipefail

repository_root=$(git rev-parse --show-toplevel)
manifest=${1:-"$repository_root/rendered/all.yaml"}

if [[ ! -f "$manifest" ]]; then
  echo "Manifest does not exist: $manifest" >&2
  exit 1
fi

temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT
crds="$temporary_directory/crds.yaml"

yq eval 'select(.kind == "CustomResourceDefinition")' "$manifest" > "$crds"
kubectl apply --server-side --field-manager=homelab-bootstrap -f "$crds"
kubectl wait --for=condition=Established --timeout=5m customresourcedefinition --all

# CRDs are established before custom resources are submitted. Reapplying the
# CRDs as part of the full artifact is intentional and idempotent.
kubectl apply --server-side --field-manager=homelab-bootstrap -f "$manifest"
