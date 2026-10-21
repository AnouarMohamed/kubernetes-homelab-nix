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
- CI runners may not expose KVM. The VM test is still built and is run only
  when virtualization is available.

## Component status

| Component | Status | Notes |
| --- | --- | --- |
| Source inventory | done | 299 configuration files recorded |
| Typed homelab options | unverified | Awaiting CI Nix evaluation |
| Three NixOS hosts | unverified | Build-only, no hardware deployment |
| Cilium and kube-vip | unverified | Render/build validation only |
| Argo CD and Rollouts | unverified | Generated repository targets |
| Longhorn | unverified | Highest-risk component |
| CloudNativePG and Velero | unverified | No live S3 tests |
| OpenBao and External Secrets | unverified | Placeholder secrets only |
| Kyverno and Trivy | unverified | CLI validation delegated to CI |
| Observability | unverified | Prometheus, Loki, Alloy, Tempo, OTel, Sloth, blackbox |
| Applications | unverified | Keycloak, Vaultwarden, Homepage, Uptime Kuma, Whoami, Sentinel |
| Chaos Mesh | unverified | No experiments are executed |
| Cloudflare Terranix | unverified | Evaluation only; no plan/apply |
| AWS validation environment | skipped | Disposable source-only infrastructure |
| Normalized parity | unverified | CI parity report is authoritative |

