# Nix migration record

## Baseline

- Source: `AnouarMohamed/kubernetes-homelab`
- Source commit: `4ec96ea5f06a447905a2b4ac20368c61d111c4d7`
- Source path: `/home/anouar/kubernetes-homelab` (read-only)
- Investigation date: 2026-10-21
- Configuration inventory: 299 YAML/YML/JSON/TOML files
- Kubernetes target: k3s `1.35.8+k3s1`; declared minor `1.35`
- Local Nix: isolated Nix 2.20.6 used for evaluation/build validation

The inventory is maintained in `docs/source-inventory.txt`. Kubernetes YAML was
converted once into readable Nix attrsets and is now maintained as Nix. Source
YAML is not loaded at evaluation time.

## Mapping

| Source | Nix destination | Strategy |
| --- | --- | --- |
| `config/homelab.yaml` | `nix/config.nix`, `nix/modules/homelab-options.nix` | Typed three-node reference configuration |
| `infra/ansible/**` | `nix/hosts`, `nix/modules/os` | NixOS and disko modules |
| Kubernetes YAML | `nix/modules/k8s`, `nix/policies` | Kubenix resources and custom resources |
| Helm/Kustomize values | Component modules | Nix attrsets and pinned charts |
| `apps/sentinel` | `apps/sentinel` | Go service and reproducible OCI packages |
| `infra/tofu` | `nix/terranix/cloudflare.nix` | Cloudflare resources only |
| Temporary AWS validation | None | Disposable 345-line validation environment excluded |
| CI and tool YAML | `nix/ci`, `nix/tools` | Nix definitions with drift-checked outputs |
| Grafana JSON | Observability resources | JSON retained and embedded in ConfigMaps |

## Deliberate parity exceptions

1. The 39 legacy Argo CD Applications/ApplicationSets are replaced with one
   Application that reconciles `rendered/all.yaml`. Their old paths do not
   exist in this repository and retaining them would produce a broken GitOps
   control plane.
2. Build-only Kustomize and ksops generator documents are excluded from the
   runtime artifact. They describe how the source tree was assembled and are
   not Kubernetes API resources.
3. Four unused, unnamespaced NetworkPolicy component templates are excluded.
   Their namespaced rendered instances remain.
4. A second legacy snapshot-controller Deployment is removed because it shares
   an object identity with the chart-owned controller. Exact duplicate objects
   are collapsed; conflicting duplicates fail evaluation.
5. Prometheus admission webhook certificates are owned by cert-manager. Helm
   patch hooks are disabled because the aggregate renderer intentionally does
   not execute chart hooks.
6. The optional host cloudflared service is disabled. Kubernetes owns
   application ingress; a host tunnel may be enabled only with a different,
   externally provisioned private-route tunnel identity.
7. General application admission controls are promoted from audit mode to
   enforcement (`Deny` for native ValidatingAdmissionPolicy resources and
   `Enforce` for Kyverno ClusterPolicy resources). Image signature verification
   remains `Audit` until the first keyless-signed workflow release is promoted,
   as explained in `docs/security.md`.

These exceptions preserve the intended runtime behavior while removing source
assembly artifacts, conflicts, or fail-open policy. Any future semantic change
must be added here.

## Generated-file exceptions

The consuming tools require these generated formats: `rendered/**/*.yaml`,
`.github/workflows/*.yaml`, `.gitlab-ci.yml`, `.sops.yaml`, `renovate.json`,
`.gitleaks.toml`, and `.markdownlint.json`. Nix generates them and CI rejects
drift. No generated Kubernetes YAML should be edited directly.

## Verification model

The manifest integrity gate derives namespace scope and served APIs from the
aggregate itself. It rejects duplicate identities, missing namespaces, custom
resources without a matching CRD, build-only objects, Kubernetes minor skew,
floating workload images, and invalid GitOps roots.

Kubeconform uses a fixed-output, commit-pinned Kubernetes 1.34.12/CRD Catalog
schema subset. Missing schemas are reported as skipped because the catalog does
not yet cover every pinned 1.35 resource. The integrity gate proves CRD/API
presence but not every custom-resource field shape; those skipped resources
remain schema-**UNVERIFIED** rather than falling back to an online mutable
catalog.

## Current evidence

- On 2026-10-22, the locked flake checks built the three NixOS host closures,
  the installer ISO, both Nix OCI images, and the three-node k3s HA VM test.
  The HA test formed quorum, stopped the node hosting the test workload, kept
  the surviving API healthy, and observed the workload reschedule.
- The aggregate contains 934 resources, 195 CRDs, and 231 served custom APIs.
  Its integrity gate found no duplicate identities, missing namespaces,
  unsupported custom APIs, floating workload images, stale GitOps paths, or
  Pod Security version skew. Kubeconform reported 698 valid, 0 invalid, 0
  errors, and 236 explicitly skipped resources under the pinned schema model.
- All 10 Kyverno positive/negative expectations passed without policy-load
  errors. Nix formatting, statix, deadnix, shellcheck, generated-file drift,
  semantic-parity, site-contract, handwritten-YAML, and secret-leak gates passed.
- Sentinel unit tests with race detection, `go vet`, and both generated GitHub
  Actions workflows were validated for this worktree.
- Public multi-architecture Sentinel `v0.2.0` images were published to GHCR by
  immutable digest with linux/amd64 and linux/arm64 payloads, SBOMs, and
  provenance attestations. The signature exception is documented in
  `docs/security.md`.
- Physical installation, disk replacement, live etcd failure, Cloudflare,
  object storage, backup restoration, and user-facing SLOs remain
  **UNVERIFIED** until exercised in the deployment environment.

## Component status

| Component | Build-time status | Environment-dependent evidence |
| --- | --- | --- |
| Three NixOS hosts | Built/evaluated by flake checks | Physical install and device drivers unverified |
| Cilium and kube-vip | Rendered and integrity checked | VIP/MTU/failover unverified |
| Argo CD and Rollouts | Rendered with one valid repository root | Live reconciliation unverified |
| Longhorn | Host prerequisites and resources build | Disk loss/rebuild unverified |
| CloudNativePG and Velero | CRDs/resources validated where schemas exist | S3 backup/restore unverified |
| OpenBao and External Secrets | Secret references render without plaintext | Real provider/rotation unverified |
| Kyverno and Trivy | Policy tests and resources in the check graph | Runtime enforcement observation unverified |
| Observability | Rules, dashboards, and operators render | Alert delivery/SLO measurement unverified |
| Applications | Images and manifests build | User acceptance and state restore unverified |
| Chaos Mesh | Resources render | Destructive experiments are not executed |
| Cloudflare Terranix | Configuration evaluates | No plan or apply is performed |
