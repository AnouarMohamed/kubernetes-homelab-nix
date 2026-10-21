#!/usr/bin/env bash
set -euo pipefail

root=$1

inventory_count=$(wc -l <"$root/docs/source-inventory.txt")
if [[ $inventory_count -ne 299 ]]; then
  echo "Expected 299 inventoried source configuration files, found $inventory_count" >&2
  exit 1
fi

required_files=(
  nix/modules/os/k3s-ha.nix
  nix/modules/os/kube-vip.nix
  nix/modules/os/cloudflared.nix
  nix/modules/k8s/cilium.nix
  nix/modules/k8s/argocd.nix
  nix/modules/k8s/argo-rollouts.nix
  nix/modules/k8s/cert-manager.nix
  nix/modules/k8s/external-dns.nix
  nix/modules/k8s/external-secrets.nix
  nix/modules/k8s/longhorn.nix
  nix/modules/k8s/cloudnative-pg.nix
  nix/modules/k8s/velero.nix
  nix/modules/k8s/openbao.nix
  nix/modules/k8s/chaos-mesh.nix
  nix/modules/k8s/observability.nix
  nix/modules/k8s/apps.nix
  nix/policies/default.nix
  nix/policies/resources.nix
  nix/terranix/cloudflare.nix
  nix/packages/sentinel.nix
)

for path in "${required_files[@]}"; do
  if [[ ! -f $root/$path ]]; then
    echo "Missing migrated component: $path" >&2
    exit 1
  fi
done

required_manifest_markers=(
  cilium.io
  argoproj.io
  cert-manager.io
  gateway.networking.k8s.io
  external-secrets.io
  longhorn.io
  snapshot.storage.k8s.io
  postgresql.cnpg.io
  velero.io
  kyverno.io
  aquasecurity.github.io
  chaos-mesh.org
  monitoring.coreos.com
  sloth.slok.dev
  cloudflared
  openbao
  keycloak
  vaultwarden
  homepage
  uptime-kuma
  whoami
  sentinel-api
  sentinel-worker
  loki
  alloy
  tempo
  opentelemetry
  blackbox
)

for marker in "${required_manifest_markers[@]}"; do
  if ! rg --fixed-strings --quiet "$marker" "$root/rendered/all.yaml"; then
    echo "Rendered parity marker missing: $marker" >&2
    exit 1
  fi
done
