package config

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"os"
	"regexp"
	"strconv"
	"time"
)

var targetIDPattern = regexp.MustCompile(`^[a-z][a-z0-9-]{0,62}$`)

type Target struct {
	ID               string `json:"id"`
	Name             string `json:"name"`
	URL              string `json:"url"`
	Public           bool   `json:"public"`
	ExpectedStatuses []int  `json:"expectedStatuses,omitempty"`
}

type Config struct {
	DatabaseURL   string
	ListenAddr    string
	MetricsAddr   string
	OTLPEndpoint  string
	ProbeInterval time.Duration
	ProbeTimeout  time.Duration
	ProbeWorkers  int
	Targets       []Target
}

func Load(requireTargets bool) (Config, error) {
	cfg := Config{
		DatabaseURL:  os.Getenv("DATABASE_URL"),
		ListenAddr:   envOrDefault("LISTEN_ADDR", ":8080"),
		MetricsAddr:  envOrDefault("METRICS_ADDR", ":9090"),
		OTLPEndpoint: os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
	}
	if cfg.DatabaseURL == "" {
		return Config{}, errors.New("DATABASE_URL is required")
	}

	var err error
	cfg.ProbeInterval, err = durationFromEnv("PROBE_INTERVAL", 30*time.Second)
	if err != nil {
		return Config{}, err
	}
	cfg.ProbeTimeout, err = durationFromEnv("PROBE_TIMEOUT", 5*time.Second)
	if err != nil {
		return Config{}, err
	}
	if cfg.ProbeTimeout >= cfg.ProbeInterval {
		return Config{}, errors.New("PROBE_TIMEOUT must be shorter than PROBE_INTERVAL")
	}
	cfg.ProbeWorkers, err = integerFromEnv("PROBE_WORKERS", 4, 1, 32)
	if err != nil {
		return Config{}, err
	}

	if !requireTargets {
		return cfg, nil
	}
	if err := json.Unmarshal([]byte(os.Getenv("SENTINEL_TARGETS_JSON")), &cfg.Targets); err != nil {
		return Config{}, fmt.Errorf("parse SENTINEL_TARGETS_JSON: %w", err)
	}
	if len(cfg.Targets) == 0 || len(cfg.Targets) > 32 {
		return Config{}, errors.New("SENTINEL_TARGETS_JSON must contain 1 to 32 targets")
	}
	seen := make(map[string]struct{}, len(cfg.Targets))
	for index, target := range cfg.Targets {
		if !targetIDPattern.MatchString(target.ID) || target.Name == "" {
			return Config{}, fmt.Errorf("target %d has an invalid id or empty name", index)
		}
		if _, exists := seen[target.ID]; exists {
			return Config{}, fmt.Errorf("target id %q is duplicated", target.ID)
		}
		seen[target.ID] = struct{}{}
		parsed, parseErr := url.ParseRequestURI(target.URL)
		if parseErr != nil || parsed.Scheme != "https" || parsed.Host == "" || parsed.User != nil {
			return Config{}, fmt.Errorf("target %q must use an HTTPS URL without user information", target.ID)
		}
		if len(target.ExpectedStatuses) > 16 {
			return Config{}, fmt.Errorf("target %q has more than 16 expected statuses", target.ID)
		}
		statusSeen := make(map[int]struct{}, len(target.ExpectedStatuses))
		for _, status := range target.ExpectedStatuses {
			if status < 100 || status > 599 {
				return Config{}, fmt.Errorf("target %q has invalid expected status %d", target.ID, status)
			}
			if _, exists := statusSeen[status]; exists {
				return Config{}, fmt.Errorf("target %q repeats expected status %d", target.ID, status)
			}
			statusSeen[status] = struct{}{}
		}
	}
	return cfg, nil
}

func integerFromEnv(name string, fallback, minimum, maximum int) (int, error) {
	value := os.Getenv(name)
	if value == "" {
		return fallback, nil
	}
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed < minimum || parsed > maximum {
		return 0, fmt.Errorf("%s must be an integer between %d and %d", name, minimum, maximum)
	}
	return parsed, nil
}

func envOrDefault(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func durationFromEnv(name string, fallback time.Duration) (time.Duration, error) {
	value := os.Getenv(name)
	if value == "" {
		return fallback, nil
	}
	parsed, err := time.ParseDuration(value)
	if err != nil || parsed <= 0 {
		return 0, fmt.Errorf("%s must be a positive duration", name)
	}
	return parsed, nil
}
