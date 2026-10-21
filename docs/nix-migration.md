# Nix migration record

## Baseline

- Source: `AnouarMohamed/kubernetes-homelab`
- Source commit: `4ec96ea5f06a447905a2b4ac20368c61d111c4d7`
- Source path: `/home/anouar/kubernetes-homelab` (read-only)
- Investigation date: 2026-10-21
- Configuration inventory: 299 YAML/YML/JSON/TOML files
- Nix availability: not installed locally
- Network availability: available during repository construction
- Local Nix status: **UNVERIFIED**; GitHub Actions is the verification authority

The inventory is maintained in `docs/source-inventory.txt`. Kubernetes YAML is
converted once into readable Nix attrsets and then maintained as Nix. It is not
loaded from copied YAML or JSON at evaluation time.

## Mapping

| Source | Nix destination | Strategy |
| --- | --- | --- |
| `config/homelab.yaml` | `nix/config.nix`, `nix/modules/homelab-options.nix` | Typed placeholder configuration |
| `infra/ansible/**` | `nix/hosts`, `nix/modules/os` | NixOS and disko modules |
| Kubernetes YAML | `nix/modules/k8s`, `nix/policies` | Kubenix resources/custom resources |
| Helm/Kustomize values | component modules | Nix attrsets and pinned charts |
| `apps/sentinel` source | `apps/sentinel` | Source copied as-is; images built with Nix |
| `infra/tofu` | `nix/terranix/cloudflare.nix` | Cloudflare resources only |
| temporary AWS validation | none | Skipped; 345-line disposable validation environment is out of scope |
| CI and tool YAML | `nix/ci`, `nix/tools` | Nix definitions with generated committed outputs |
| Grafana JSON | `nix/modules/k8s/observability/dashboards` | JSON retained and embedded in ConfigMaps |

## Generated-file exceptions

The following YAML is permitted because the consuming tool requires YAML and
the file is generated from Nix: `rendered/**/*.yaml`, `.github/workflows/*.yaml`,
`.gitlab-ci.yml`, and `.sops.yaml`. Drift checks cover every exception.

## Assumptions and open questions

- The repository is build-only and will not create infrastructure.
- Placeholder addresses intentionally do not match the source environment.
- GitHub is the only publication target; GitLab CI remains a generated parity
  artifact.
- Longhorn remains the highest-risk component because of host iSCSI/FHS and
  kernel dependencies. Hardware behavior cannot be confirmed in CI.
- Kubeconform uses a hash-verified, commit-pinned subset of Kubernetes 1.34.12
  and CRD Catalog schemas assembled by `nix/checks/schemas.nix`. Resources
  without a bundled schema are reported as skipped and remain schema-
  unverified rather than using an unpinned online catalog.
- GitHub's Ubuntu runner exposes KVM and executes the three-node HA test.
- Build, evaluation, schema, and VM-test status below does not imply a live
  deployment to physical nodes, Cloudflare, object storage, or Kubernetes.

## Component status

| Component | Status | Notes |
| --- | --- | --- |
| Source inventory | done | 299 configuration files recorded |
| Typed homelab options | CI evaluated | Placeholder coverage passes |
| Three NixOS hosts | CI built | All toplevels build; no hardware deployment |
| Cilium and kube-vip | rendered | Nix evaluation and manifest checks; no live VIP test |
| Argo CD and Rollouts | schema verified | Application tree and Rollout use pinned schemas |
| Longhorn | rendered | Host prerequisites build; hardware behavior unverified |
| CloudNativePG and Velero | partly schema verified | CNPG core schemas pass; no live S3 tests |
| OpenBao and External Secrets | partly schema verified | Placeholder secrets only; ESO core schemas pass |
| Kyverno and Trivy | CLI verified | Ten Kyverno policy tests pass in CI |
| Observability | partly schema verified | Prometheus CRDs pass; remaining operators render |
| Applications | CI built/rendered | Sentinel tests and images build; application manifests render |
| Chaos Mesh | rendered | No destructive experiments are executed |
| Cloudflare Terranix | CI evaluated | Configuration builds; no plan/apply |
| AWS validation environment | skipped | Disposable source-only infrastructure |
| Normalized parity | CI checked | 299-file baseline, module presence, and rendered component markers |

## Validation evidence

- GitHub Actions run `39632545116` completed the full flake check, all three
  host builds, installer ISO, Sentinel package/images, Kyverno tests, secret
  scan, and the three-node k3s failure/rescheduling test.
- Local non-Nix checks cover Go tests, handwritten-YAML policy, placeholder
  documentation, semantic parity, and whitespace errors. Local Nix execution
  remains **UNVERIFIED** because Nix is intentionally not installed.
- Live infrastructure and physical-node behavior remain **UNVERIFIED** by
  design; this repository performs build-only validation.

