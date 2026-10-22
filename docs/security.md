# Security model

## Protected assets

The primary assets are cluster-admin access, workload credentials, signing
identity, TLS private keys, database contents, backup data, and the integrity
of the rendered deployment artifact.

## Trust boundaries

- GitHub review and CI authorize changes to desired state.
- GHCR supplies workload images by immutable digest.
- The private SOPS overlay and External Secrets cross the secret boundary.
- Cloudflare and S3-compatible storage are external administrative domains.
- The host firewall separates the administrator/node network from untrusted
  networks; Cilium governs forwarded workload traffic inside the cluster.

## Preventive controls

- Root SSH login and password authentication are disabled. A named non-root
  administrator reaches SSH and the Kubernetes API only from `adminCidr`.
- k3s inter-node ports are limited to the declared node network. Forwarding is
  left to Cilium because blanket host rejection would bypass its policy model.
- Workloads use digest-pinned images, restrictive security contexts, and
  namespace Pod Security labels. Kyverno rejects the enforceable application
  policy violations retained from the source platform.
- GitHub Actions are pinned to commits and have job-level least-privilege
  permissions. Releases publish multi-architecture images with SBOM and
  provenance attestations, followed by keyless Sigstore signing in GitHub.
- CI scans for secrets and rejects generated artifact drift.

## Deliberate exceptions

The image-signature admission policy remains in `Audit` during migration. The
configured Sentinel `v0.2.0` images were manually published from the documented
worktree with SBOM and provenance attestations, but outside GitHub OIDC and are
therefore not keyless signed. A `Deny` rule would make them unschedulable.
Promote it to `Deny` only after a workflow-published release is verified against
the configured GitHub OIDC identity. This is a tracked fail-open boundary, not
an implicit weakening.

Argo CD's rendered-artifact project permits all cluster-scoped kinds. The
artifact installs CRDs and cluster policy, so a narrower static list would be
misleading. The compensating boundary is a single allowed repository and path,
protected review, immutable history, and fail-closed manifest validation.

The bootstrap script intentionally applies the selected current context. It
prints that context, requires an interactive confirmation unless
`HOMELAB_BOOTSTRAP_CONFIRM=yes` is set, and is never called from CI.

## Secret lifecycle

1. Create values outside the repository on an encrypted workstation.
2. Encrypt them to the deployment age recipients before they reach Git.
3. Keep age private keys out of Nix expressions and the Nix store.
4. Grant service accounts access only to their required external secret keys.
5. Rotate the source value, confirm reconciliation, then revoke the previous
   value. Treat logs and generated support bundles as potentially sensitive.

No encrypted secret document is committed by the reference profile. A private
deployment supplies `homelab.sopsFile` and `homelab.ageRecipient` together;
without them SOPS activation is disabled and k3s expects its token at the
root-only runtime path documented in the deployment contract.

## Vulnerability response

Follow [`respond-to-security-findings.md`](runbooks/respond-to-security-findings.md).
For a suspected credential leak, revoke and rotate before investigating blast
radius. Do not open a public issue containing an exploit, token, hostname,
address, support bundle, or customer data. Use the private reporting process in
[`SECURITY.md`](../SECURITY.md).

