# Operate self-hosted applications

Homepage and whoami are reconstructible from Git. Uptime Kuma and Vaultwarden
hold user state and require verified off-cluster backups.

For an incident, first check Argo health, pod events, PVC attachment, service
endpoints, certificates, and namespace policy. Restart only the affected
workload after capturing its previous logs. Make lasting changes in Nix and
deploy through GitOps.

Before upgrades, read upstream migration notes, verify a recent restore, render
and review the manifest diff, and keep the prior digest available. For
Vaultwarden, protect database and attachment consistency and rotate exposed
admin/session credentials. For Uptime Kuma, suppress notifications during an
approved maintenance window and verify monitors afterward.

