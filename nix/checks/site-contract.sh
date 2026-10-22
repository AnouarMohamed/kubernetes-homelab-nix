#!/usr/bin/env bash
set -euo pipefail

root=$1
if rg --quiet '(REPLACE_WITH_|example[.]invalid|192[.]0[.]2[.]|00000000-0000-0000-0000-000000000000)' \
  "$root/nix/config.nix" "$root/nix/hosts" "$root/nix/modules/os"; then
  echo "Reference configuration contains an unresolved deployment token" >&2
  exit 1
fi

rg --fixed-strings --quiet 'pci-0000:00:17.0-ata-3' "$root/nix/config.nix"
rg --fixed-strings --quiet 'enp0s31f6' "$root/nix/config.nix"
rg --fixed-strings --quiet 'homelab.sopsFile != null' "$root/nix/modules/os/sops.nix"
