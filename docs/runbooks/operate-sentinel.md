# Operate Sentinel

Sentinel has independently deployable API and worker images backed by
PostgreSQL and OpenTelemetry. The API exposes service traffic on port 8080; the
worker exposes metrics on port 9090.

The public read API provides:

- `GET /api/v1/status` for the latest sample per public service;
- `GET /api/v1/summary` for the aggregate current state;
- `GET /api/v1/services/{id}/history?limit=50` for status transitions; and
- `GET /api/v1/services/{id}/slo?window=24h&objective=99.9` for sampled
  availability, error-budget remaining, burn rate, and p50/p95/p99 latency.

SLO windows are deliberately bounded to `1h`, `6h`, `24h`, `7d`, or `30d`.
The worker retains raw probe observations for 30 days by default and prunes
them every six hours. Set `OBSERVATION_RETENTION` to a Go duration of at least
24 hours when a different retention boundary is required.

When either component is unhealthy, correlate its immutable image digest and
Argo revision, then check previous logs, probes, PostgreSQL readiness and pool
pressure, queue/backlog indicators, and trace-export errors. Avoid restarting
both components and the database together.

Release images through `.github/workflows/release-images.yaml`. The workflow
builds `linux/amd64` and `linux/arm64`, attaches SBOM and provenance, and signs
the pushed index with the repository's GitHub OIDC identity. Promote only the
index digest into `nix/config.nix`; never deploy a floating tag.

Manual releases accept canonical stable SemVer only (for example `v0.4.0`).
The workflow refuses to overwrite an existing version. It publishes the
repository-owned `homelab-nix-sentinel-api` and
`homelab-nix-sentinel-worker` packages; the similarly named legacy packages
belong to the predecessor repository and are not release targets here.

After a rollout, verify API readiness, worker progress, database errors,
latency/error SLOs, traces, and metrics for a complete observation window.

