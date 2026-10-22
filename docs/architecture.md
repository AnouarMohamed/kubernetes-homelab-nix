# Architecture

This is a three-node, highly available Kubernetes platform built from one
pinned Nix dependency graph and reconciled from one generated manifest. The
diagram distinguishes build-time supply chain, external trust boundaries,
cluster control, application traffic, state, and telemetry.

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

Solid arrows are runtime or reconciliation flows. The dotted arrow is the
release identity boundary: GitHub OIDC signs future workflow releases, while
the currently published bootstrap images are digest-pinned and explicitly
documented as manually published.

## Physical topology

The committed profile describes three identical PCs. Each is an
`x86_64-linux` k3s server with an Intel Core i7-8650U (4 cores / 8 threads),
32 GiB RAM, and a 512 GB SATA SSD. All nodes use the same verified controller
path and Intel wired interface name; only hostname and address differ.

```mermaid
flowchart TB
  client[Administrators and automation] --> api[10.10.0.10 API virtual IP]
  ingress[10.10.0.20-39 service address pool] --> services[Kubernetes services]

  subgraph quorum[Failure domain: one LAN, three physical nodes]
    direction LR
    n1[node1 · 10.10.0.11 · etcd voter]
    n2[node2 · 10.10.0.12 · etcd voter]
    n3[node3 · 10.10.0.13 · etcd voter]
    n1 <--> n2
    n2 <--> n3
    n3 <--> n1
  end

  api --> quorum
  services --> quorum
  quorum --> volumes[Three-way Longhorn replication]

  classDef endpoint fill:#172554,stroke:#60a5fa,color:#eff6ff
  classDef node fill:#064e3b,stroke:#34d399,color:#ecfdf5,stroke-width:2px
  classDef storage fill:#422006,stroke:#fbbf24,color:#fffbeb
  class client,api,ingress,services endpoint
  class n1,n2,n3 node
  class volumes storage
```

The SATA path `/dev/disk/by-path/pci-0000:00:17.0-ata-3` and interface
`enp0s31f6` were observed on the reference PC. Because installation is
destructive, the installer must confirm the same model, size, controller path,
and interface on all three machines before partitioning.

## Ownership and trust boundaries

| Layer | Owner | Enforced contract |
| --- | --- | --- |
| Dependencies | `flake.lock` and fixed-output hashes | Evaluation performs no unpinned fetch |
| Hosts | NixOS and Disko modules | Same reviewed OS, disk, network, k3s, and firewall state on every node |
| Bootstrap | `scripts/bootstrap-cluster.sh` | CRDs establish before dependent custom resources |
| Desired cluster state | Argo CD | Reconciles only `rendered/all.yaml` from `main` |
| Workload artifacts | GHCR digests | Runtime never resolves a floating image tag |
| Secrets | Private SOPS module and External Secrets | Plaintext never enters Git or a Nix store path |
| Public edge | Cloudflare variables supplied at apply time | Account, zone, public domain, and credentials stay outside Git |
| Recovery | Longhorn, CNPG, Velero, and runbooks | Restore is accepted only after an environment-specific drill |

## Reconciliation and boot order

1. Nix builds identical host closures and a deterministic Kubernetes artifact.
2. Node 1 initializes embedded etcd; nodes 2 and 3 join through the kube-vip
   endpoint using one out-of-band k3s token.
3. Bootstrap establishes CRDs before applying namespaces, RBAC, storage,
   networking, controllers, and custom resources.
4. Argo CD adopts the same artifact and becomes its sole reconciler.
5. Kyverno rejects policy violations; integrity and schema gates reject
   unsupported APIs, duplicate identities, missing namespaces, and mutable
   workload images before merge.

## Availability limits

Three etcd voters tolerate one unavailable node. Application anti-affinity,
budgets, replicated volumes, and database instances reduce correlated
failures, but this is one power, network, and geographic domain. Two node
failures lose quorum. Backups outside the cluster are therefore part of the
availability design, not an optional extra.
