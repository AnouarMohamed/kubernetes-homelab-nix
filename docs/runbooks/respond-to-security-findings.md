# Respond to security findings

## Critical container vulnerability detected

1. Confirm the finding applies to the deployed image digest and reachable code,
   not only a mutable tag or unused package.
2. If exploitation is suspected, isolate the workload with network policy,
   preserve pod/runtime/audit evidence, and rotate all reachable credentials.
3. Update the base or dependency, rebuild both architectures, inspect SBOM and
   provenance, and publish an immutable signed release.
4. Update the digest in `nix/config.nix`, run the full validation graph, and
   deploy through GitOps.
5. Verify the old digest is no longer running and document exposure window,
   blast radius, evidence, and follow-up controls.

Do not weaken admission policy, disable scanning, or paste scanner output that
contains private registry or infrastructure data into a public issue.

