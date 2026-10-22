# Operate Sentinel

Sentinel has independently deployable API and worker images backed by
PostgreSQL and OpenTelemetry. The API exposes service traffic on port 8080; the
worker exposes metrics on port 9090.

When either component is unhealthy, correlate its immutable image digest and
Argo revision, then check previous logs, probes, PostgreSQL readiness and pool
pressure, queue/backlog indicators, and trace-export errors. Avoid restarting
both components and the database together.

Release images through `.github/workflows/release-images.yaml`. The workflow
builds `linux/amd64` and `linux/arm64`, attaches SBOM and provenance, and signs
the pushed index with the repository's GitHub OIDC identity. Promote only the
index digest into `nix/config.nix`; never deploy a floating tag.

After a rollout, verify API readiness, worker progress, database errors,
latency/error SLOs, traces, and metrics for a complete observation window.

