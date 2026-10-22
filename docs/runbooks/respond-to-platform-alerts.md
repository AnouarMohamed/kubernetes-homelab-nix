# Respond to platform alerts

## Watchdog

Watchdog should always fire. If it disappears, treat the alerting path as
failed: check Prometheus targets and rules, Alertmanager pods and routes, then
the external notification receiver. Verify with a controlled test alert.

## Node down

Confirm the node is unreachable from another node before power cycling it.
Check switch/link state, power, disk health, and k3s logs. Preserve etcd quorum:
never restart a second server while one is unavailable. After recovery, verify
`Ready`, etcd membership, Cilium health, Longhorn replicas, and rescheduling.

## Etcd leader changes

Correlate leader churn with node restarts, latency, CPU pressure, disk latency,
and packet loss. Stop non-essential changes. If quorum is healthy, repair one
fault domain at a time. Do not remove or re-add a member without a current etcd
snapshot and an explicit membership plan.

## Disk pressure

Identify whether image layers, logs, Longhorn replicas, or database data grew.
Pause noisy workloads and backups if required. Reclaim only known disposable
data; never manually delete k3s, containerd, Longhorn, or PostgreSQL internals.
Verify kubelet pressure clears and affected storage replicas rebuild.

## Certificate expiry

Identify the exact Secret and owning Certificate. Check cert-manager events,
issuer readiness, DNS/HTTP reachability, and rate limits. Avoid deleting a
working Secret until issuance succeeds. Verify the renewed chain from outside
the cluster and confirm consumers reloaded it.

## Argo CD out of sync

Compare the Application revision and diff with `rendered/all.yaml`. Stop if the
diff includes an unexpected destructive operation, CRD replacement, or Secret
data. Fix desired state in Git; do not normalize manual cluster edits into Git
without review. Confirm `Synced` and `Healthy` after reconciliation.

## Backup failure

Determine whether the failed unit is Velero, CloudNativePG, or a volume
snapshot. Check credentials by reference only, endpoint/DNS/TLS, repository
capacity, and retention policy. Rerun after correction and perform a restore
into an isolated namespace before declaring backup health restored.

## Longhorn degraded

Locate affected volumes and replicas, then verify node, disk, and instance
manager health. Protect the remaining healthy replica: do not detach, salvage,
or delete replicas simultaneously. Allow one rebuild at a time and verify
application checksums or database health afterward.

## Container restarts

Inspect the previous termination reason, events, probes, limits, and dependency
latency. Distinguish rollout restarts from crashes and OOM kills. Correct the
cause through Git, monitor a full rollout window, and confirm error rate and
latency return to baseline.

## API latency

Separate Kubernetes API latency from application API latency. For Kubernetes,
check etcd latency, apiserver saturation, admission webhooks, and network loss.
For applications, check traces, database pools, downstream latency, and
resource throttling. Freeze rollouts until the bottleneck is understood.

## SLO budget burn

Confirm the burn rate across both short and long windows. Identify the user
journey and recent change responsible, then roll back or disable that change if
the rollback is safe. Record impact duration, consumed budget, and a concrete
prevention action after service is stable.

