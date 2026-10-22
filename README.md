# Kubernetes Homelab, Rebuilt with Nix

[![Production validation](https://github.com/AnouarMohamed/kubernetes-homelab-nix/actions/workflows/ci.yaml/badge.svg)](https://github.com/AnouarMohamed/kubernetes-homelab-nix/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A reproducible, security-conscious three-node k3s platform expressed as one
locked Nix flake. NixOS hosts, Kubernetes resources, policy, generated CI,
and the in-repo Sentinel service are evaluated together and shipped as an
auditable deployment artifact.

This repository is production-shaped, not a claim that somebody else's
hardware is production-ready. Builds, manifests, and policy are tested without
real credentials. Hardware failure, storage recovery, DNS, tunnels, and object
storage must be exercised in the target environment before serving real users.

## Why this repository is different

- **One locked graph:** operating systems, charts, CRDs, tools, Go modules,
  container bases, and actions are pinned.
- **No manifest pile:** typed Nix modules generate a single deterministic
  Kubernetes artifact; committed YAML is drift-checked output.
- **Secure defaults:** non-root SSH, CIDR-scoped control-plane access,
  digest-pinned workloads, namespace policy, Kyverno enforcement, and no
  committed credentials.
- **Supply-chain evidence:** Sentinel images are multi-architecture, include
  BuildKit provenance and SBOM attestations, and the release workflow applies
  keyless Sigstore signatures.
- **A real Go service:** Sentinel runs bounded concurrent probes, persists
  samples and transitions in PostgreSQL, exposes windowed SLO/error-budget
  analytics, emits Prometheus metrics and OpenTelemetry traces, and ships with
  race-tested unit and database integration suites.
- **Fail-closed integrity checks:** duplicate identities, absent namespaces,
  missing CRDs, floating images, version skew, leaked build artifacts, and
  broken GitOps paths fail validation.
- **Honest operations:** recovery targets and known exceptions are documented;
  unexecuted hardware or cloud checks are explicitly marked unverified.

## Architecture

```mermaid
flowchart LR
  operator[Operator]
  users[Internet users]

  subgraph supply[Supply chain]
    direction TB
    git[Git repository]
    ci[CI security and quality gates]
    nix[Nix build graph]
    manifests[Rendered Kubernetes artifact]
    registry[GHCR multi-architecture images]
    git --> ci --> nix
    nix --> manifests
    nix --> registry
  end

  subgraph external[External services]
    direction TB
    edge[Cloudflare DNS and tunnel]
    object[Versioned S3-compatible backup store]
    probes[HTTPS services monitored by Sentinel]
  end

  subgraph cluster[Three identical NixOS nodes]
    direction TB

    subgraph control[Control and reconciliation]
      direction LR
      vip[kube-vip API endpoint]
      k3s[k3s servers and embedded etcd quorum]
      argo[Argo CD]
      policy[Kyverno policy engine]
      secrets[External Secrets and OpenBao]
      vip --> k3s
      argo --> k3s
      policy --> k3s
      secrets --> k3s
    end

    subgraph traffic[Traffic plane]
      direction LR
      tunnel[cloudflared connector]
      gateway[Cilium Gateway API]
      apps[Keycloak, Vaultwarden, Homepage, Uptime Kuma]
      status[Sentinel API]
      tunnel --> gateway
      gateway --> apps
      gateway --> status
    end

    subgraph data[State and recovery]
      direction LR
      longhorn[Longhorn replicated volumes]
      postgres[CloudNativePG clusters]
      velero[Velero backup controller]
      longhorn --> postgres
      postgres --> velero
      longhorn --> velero
    end

    subgraph observe[Observability and verification]
      direction LR
      worker[Sentinel probe workers]
      metrics[Prometheus]
      dashboards[Grafana and Alertmanager]
      worker --> status
      worker --> metrics
      apps --> metrics
      k3s --> metrics
      metrics --> dashboards
    end

    k3s --> gateway
    k3s --> longhorn
    apps --> postgres
  end

  operator --> git
  ci -. signed release identity .-> registry
  manifests --> argo
  registry --> k3s
  users --> edge --> tunnel
  worker --> probes
  velero --> object

  classDef actor fill:#172554,stroke:#60a5fa,color:#eff6ff,stroke-width:2px
  classDef supplyNode fill:#312e81,stroke:#a5b4fc,color:#eef2ff
  classDef controlNode fill:#3f1d2e,stroke:#fb7185,color:#fff1f2
  classDef runtimeNode fill:#064e3b,stroke:#34d399,color:#ecfdf5
  classDef dataNode fill:#422006,stroke:#fbbf24,color:#fffbeb
  classDef externalNode fill:#292524,stroke:#a8a29e,color:#fafaf9
  class operator,users actor
  class git,ci,nix,manifests,registry supplyNode
  class vip,k3s,argo,policy,secrets controlNode
  class tunnel,gateway,apps,status,worker,metrics,dashboards runtimeNode
  class longhorn,postgres,velero dataNode
  class edge,object,probes externalNode
```

Nix owns the host and render-time graph. Argo CD owns reconciliation of the
single committed deployment artifact. Secret values remain outside Git and
arrive through the documented SOPS/External Secrets boundary.

## Fast path

```console
nix flake check --keep-going --print-build-logs
nix build .#manifests
nix run .#render
```

Inspect `result` before touching a cluster. On a deliberately selected
bootstrap context:

```console
kubectl config current-context
nix run .#bootstrap
```

The bootstrap command installs pinned CRDs first, waits for establishment, and
then server-side applies the complete artifact. It mutates the current
Kubernetes context and is never run by CI.

## Repository map

| Path | Responsibility |
| --- | --- |
| `nix/config.nix` | Non-secret three-node hardware, LAN topology, versions, and image digests |
| `nix/modules/os` | NixOS, disks, k3s, firewall, host hardening |
| `nix/modules/k8s` | Platform and application resources |
| `nix/policies` | Admission, verification, and runtime guardrails |
| `nix/checks` | Reproducibility, schema, drift, policy, and parity checks |
| `apps/sentinel` | Go API and worker plus hardened container builds |
| `rendered/all.yaml` | Generated, reviewable GitOps deployment artifact |
| `docs/runbooks` | Alert response and recovery procedures |

## Verification contract

The flake exposes checks for both supported systems. On the current system,
`nix flake check` covers formatting,
static analysis, secret scanning, generated-file drift, manifest integrity,
schema validation, Kyverno tests, Sentinel builds, all three NixOS systems,
the installer ISO, and a three-node k3s VM test. The Go CI lane independently
runs the race detector, coverage, and `go vet`.

The exact migration evidence and exceptions are tracked in
[`docs/nix-migration.md`](docs/nix-migration.md). Before deploying, read the
[`architecture`](docs/architecture.md), [`security model`](docs/security.md),
[`operating guide`](docs/operations.md), and
[`deployment contract`](docs/deployment.md).

## Non-goals

- Provisioning or changing live hardware and cloud accounts from CI.
- Storing real infrastructure addresses, credentials, or decryption keys.
- Pretending that a successful build substitutes for restore and failover
  drills on the target environment.

Licensed under the [MIT License](LICENSE).
