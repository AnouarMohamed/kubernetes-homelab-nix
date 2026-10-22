CREATE TABLE IF NOT EXISTS probe_observations (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id text NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    status text NOT NULL CHECK (status IN ('operational', 'degraded', 'down')),
    observed_at timestamptz NOT NULL,
    latency_ms integer NOT NULL CHECK (latency_ms >= 0),
    message text NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS probe_observations_service_observed_idx
    ON probe_observations (service_id, observed_at DESC);

CREATE INDEX IF NOT EXISTS probe_observations_observed_idx
    ON probe_observations (observed_at);
