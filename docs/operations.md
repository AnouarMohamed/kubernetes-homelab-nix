# Operating guide

## Service targets

These are design targets to validate in the actual environment, not measured
claims:

| State | Recovery point objective | Recovery time objective |
| --- | --- | --- |
| Git-managed stateless services | Last merged commit | 30 minutes |
| PostgreSQL | Last successful verified backup/WAL archive | 2 hours |
| Persistent application volumes | Last successful off-cluster backup | 4 hours |
| Complete cluster rebuild | Git plus latest verified backups | 8 hours |

Record achieved RPO/RTO after every restore drill. Tighten the target only
when monitoring and repeated exercises support it.

## Daily checks

1. Confirm all three nodes are `Ready` and etcd has a healthy member set.
2. Confirm Argo CD is `Healthy` and `Synced` with the expected Git revision.
3. Review firing alerts, failed CronJobs, pending pods, certificate expiry, and
   namespace policy violations.
4. Check Longhorn volume health, CloudNativePG status, Velero backup status,
   and off-cluster object-store visibility.
5. Investigate image verification audit events until enforcement is enabled.

## Change and upgrade method

1. Update exactly one pinned dependency or coherent component set.
2. Regenerate committed artifacts with `nix run .#render`.
3. Review the rendered diff, release notes, CRD conversion/storage versions,
   and rollback constraints.
4. Run `nix flake check --keep-going --print-build-logs` and independent Go
   checks. Never label an omitted check as passing.
5. Merge during an observed maintenance window. Watch Argo health, rollout
   progress, SLOs, database health, and storage replicas.
6. Roll back Git only when the component supports downgrade. Otherwise follow
   its documented forward-recovery procedure.

Kubernetes minor changes must update the k3s package, declared version, Helm
capabilities, Pod Security labels, and schema bundle together.

## Restore drills

Perform quarterly and before material storage/database changes:

- Restore PostgreSQL to an isolated namespace and validate application-level
  invariants, not only pod readiness.
- Restore a representative persistent volume and compare checksums.
- Rebuild one node from the installer and rejoin it without disturbing quorum.
- Recreate the cluster in an isolated network from Git and off-cluster backups.
- Record start/end times, data-loss window, operator actions, surprises, and
  remediation owners.

No live restore, Cloudflare, object-store, or physical-disk exercise is claimed
by this repository. Those checks remain **UNVERIFIED** until the operator
records evidence from the target environment.

## Incident entry points

- [Platform alerts](runbooks/respond-to-platform-alerts.md)
- [Security findings](runbooks/respond-to-security-findings.md)
- [SSO recovery](runbooks/recover-sso.md)
- [Self-hosted applications](runbooks/operate-self-hosted-apps.md)
- [Sentinel](runbooks/operate-sentinel.md)

