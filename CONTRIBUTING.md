# Contributing

Keep changes small, reproducible, and reviewable. Do not commit credentials or
real infrastructure addresses.

1. Update pinned sources or fixed-output hashes; do not add channels, mutable
   downloads, or impure evaluation.
2. Prefer typed `homelab.*` options and focused modules over inline blobs.
3. Explain changes to firewall, RBAC, secrets, tunnels, admission policy, or
   security contexts in the pull request.
4. Regenerate committed outputs with `nix run .#render`; do not edit generated
   YAML directly.
5. Run `nix flake check --keep-going --print-build-logs` and the Sentinel Go
   tests. State any unexecuted check as **UNVERIFIED**.
6. Document an exact migration exception whenever semantic parity changes.

The original nine migration phases remain separate historical commits. New
work should use conventional, single-purpose commits with the generated diff
in the same commit as its Nix source.

