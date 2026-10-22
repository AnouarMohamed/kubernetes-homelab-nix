package config

import "testing"

func TestLoadTargets(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://sentinel:test@database/sentinel")
	t.Setenv("SENTINEL_TARGETS_JSON", `[{"id":"public-site","name":"Public site","url":"https://status.example.test/healthz","public":true}]`)
	cfg, err := Load(true)
	if err != nil {
		t.Fatalf("Load returned an error: %v", err)
	}
	if len(cfg.Targets) != 1 || cfg.Targets[0].ID != "public-site" {
		t.Fatalf("unexpected targets: %#v", cfg.Targets)
	}
}

func TestLoadRejectsUnsafeTarget(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://sentinel:test@database/sentinel")
	t.Setenv("SENTINEL_TARGETS_JSON", `[{"id":"metadata","name":"Metadata","url":"http://169.254.169.254/","public":false}]`)
	if _, err := Load(true); err == nil {
		t.Fatal("Load accepted a non-HTTPS target")
	}
}

func TestLoadExpectedStatusesAndWorkers(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://sentinel:test@database/sentinel")
	t.Setenv("PROBE_WORKERS", "8")
	t.Setenv("SENTINEL_TARGETS_JSON", `[{"id":"redirect","name":"Redirect","url":"https://status.example.test/","expectedStatuses":[301,302]}]`)
	cfg, err := Load(true)
	if err != nil {
		t.Fatalf("Load returned an error: %v", err)
	}
	if cfg.ProbeWorkers != 8 || len(cfg.Targets[0].ExpectedStatuses) != 2 {
		t.Fatalf("unexpected configuration: %#v", cfg)
	}
}

func TestLoadRejectsDuplicateExpectedStatus(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://sentinel:test@database/sentinel")
	t.Setenv("SENTINEL_TARGETS_JSON", `[{"id":"site","name":"Site","url":"https://status.example.test/","expectedStatuses":[200,200]}]`)
	if _, err := Load(true); err == nil {
		t.Fatal("Load accepted a duplicate expected status")
	}
}
