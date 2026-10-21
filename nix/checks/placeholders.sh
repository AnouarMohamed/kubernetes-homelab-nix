#!/usr/bin/env bash
set -euo pipefail

root=$1
mapfile -t placeholders < <(
  rg --no-filename --only-matching '(PLACEHOLDER[[:alnum:]_.-]*|REPLACE_WITH_[[:alnum:]_]+|00000000-0000-0000-0000-000000000000)' \
    "$root/nix/config.nix" "$root/nix/hosts" "$root/nix/modules/os" | sort -u
)
for placeholder in "${placeholders[@]}"; do
  if ! rg --fixed-strings --quiet "$placeholder" "$root/docs/nix-bringup.md"; then
    echo "Undocumented placeholder: $placeholder" >&2
    exit 1
  fi
done

