# Repository rules

1. Verify NixOS options, package attributes, kubenix options, and chart names
   against pinned sources. Leave an explicit TODO rather than guessing.
2. Pin every dependency through `flake.lock` or a fixed-output hash. Do not use
   channels, `<nixpkgs>`, or impure fetches.
3. Never commit secrets, tokens, or real infrastructure addresses.
4. Treat `/home/anouar/kubernetes-homelab` as read-only migration input.
5. Prefer small modules and typed `homelab.*` options over inline blobs.
6. Explain security-sensitive firewall, RBAC, secret, tunnel, policy, and
   security-context choices. Do not weaken source behavior silently.
7. Keep the nine migration phases as separate commits.
8. Run `nix flake check` after each phase when Nix is available; otherwise mark
   the phase UNVERIFIED and use CI before claiming success.
9. Never call an unexecuted check passing or verified.
10. Preserve semantic parity or document the exact exception in the migration
    log.

