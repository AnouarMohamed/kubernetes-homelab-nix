# Runbooks

These runbooks favor containment and evidence preservation over blind restarts.
Before acting, capture the alert timestamp, Argo revision, affected namespace,
and recent changes. Never paste credentials or decrypted Secret values into an
issue, command transcript, or incident channel.

| Runbook | Scope |
| --- | --- |
| [Platform alerts](respond-to-platform-alerts.md) | Nodes, etcd, disks, certificates, GitOps, backups, SLOs |
| [Security findings](respond-to-security-findings.md) | Runtime and image findings |
| [SSO recovery](recover-sso.md) | Keycloak and login-path recovery |
| [Self-hosted applications](operate-self-hosted-apps.md) | Homepage, Uptime Kuma, Vaultwarden, whoami |
| [Sentinel](operate-sentinel.md) | API, worker, database, and telemetry |

