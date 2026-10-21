#!/usr/bin/env bash
set -euo pipefail

root=$1
mapfile -t files < <(find "$root" -type f \( -name '*.yaml' -o -name '*.yml' \) -print | sort)
for file in "${files[@]}"; do
  relative=${file#"$root"/}
  case "$relative" in
    rendered/*.yaml|.github/workflows/*.yaml|.gitlab-ci.yml|.sops.yaml)
      first_line=$(head -n 1 "$file")
      if [[ "$first_line" != *GENERATED* ]]; then
        echo "Allowed YAML lacks generated header: $relative" >&2
        exit 1
      fi
      ;;
    *)
      echo "Handwritten YAML is forbidden: $relative" >&2
      exit 1
      ;;
  esac
done

