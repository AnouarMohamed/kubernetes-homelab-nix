# Architecture

## Design goals

The platform is optimized for reproducibility, reviewability, and recovery on
three small control-plane nodes. A single lock file closes the build graph. A
single rendered manifest closes the GitOps graph. Every deliberate dependency
on infrastructure outside that graph is called out as an operational boundary.

## Ownership boundaries

| Layer | Owner | Contract |
| --- | --- | --- |
| Dependency graph | `flake.lock` and fixed-output hashes | Evaluation performs no unpinned fetch |
| Host operating system | NixOS modules | Declarative node, disk, network, k3s, and firewall state |
| Cluster bootstrap | `scripts/bootstrap-cluster.sh` | CRDs become established before custom resources |
| Desired cluster state | Argo CD | Reconciles only `rendered/all.yaml` from `main` |
| Secrets | Private SOPS overlay and External Secrets | No plaintext value enters Git or a Nix store path |
| Cloud edge and object storage | External operator | DNS, tunnel, bucket, and credentials are supplied out of tree |
| Persistent recovery | Longhorn, CNPG, Velero, and runbooks | Recovery is accepted only after an environment-specific drill |

## Dependency order

The rendered artifact is intentionally safe to inspect as a single file, but
bootstrap has an ordering requirement:

1. Kubernetes and platform CRDs are applied and reach `Established`.
2. Namespaces, RBAC, storage, networking, and controllers are applied.
3. Operators reconcile their custom resources.
4. Argo CD takes ownership of the same committed artifact.

The integrity check derives served custom APIs and namespace scope from the
rendered CRDs. It rejects resources whose API is unavailable, namespaced
objects without a namespace, duplicate object identities, floating workload
images, and stale GitOps source paths.

## Control plane and networking

All three nodes run the k3s server role. Node 1 initializes embedded etcd;
nodes 2 and 3 join it. kube-vip owns the control-plane virtual IP. Cilium owns
pod networking, service routing, Gateway API, and forwarded traffic policy.
Host firewall openings for etcd and k3s peer traffic are limited to the node
CIDR; SSH and the Kubernetes API are limited to the administrator CIDR.

Node addresses in the public configuration are documentation-safe TEST-NET
values. Deployment requires matching DHCP reservations or an equivalent
private network configuration supplied by the operator.

## Storage and state

Longhorn supplies general replicated volumes. CloudNativePG owns PostgreSQL
clusters and their database-specific storage class. Velero covers Kubernetes
objects and selected volume data in S3-compatible storage. These are
complementary mechanisms, not interchangeable backups. The backup service,
bucket policy, retention lock, restore credentials, and recovery drills live
outside the reproducible build boundary.

## GitOps boundary

The old per-directory application tree is intentionally collapsed into one
Argo CD Application. It points at `rendered/` in this repository, enables
pruning and self-healing, and uses server-side apply for the large aggregate.
The project allows cluster-scoped kinds because the artifact includes CRDs,
namespaces, policy, and storage definitions. That broad Kubernetes permission
is bounded by one repository allowlist, immutable review history, branch
protection, and the manifest integrity gate.

## Availability model

- Three k3s servers tolerate one control-plane node loss when etcd and the
  network are healthy.
- Workloads request multiple replicas where source behavior supports them.
- Pod disruption budgets, anti-affinity, probes, and rolling strategies reduce
  correlated application disruption.
- A three-node cluster cannot preserve quorum during two simultaneous node
  failures. It is not a substitute for regional redundancy.
- Availability claims remain design properties until measured on the target
  hardware with node-loss, network-loss, disk-loss, and restore drills.

