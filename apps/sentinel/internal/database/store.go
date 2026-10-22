package database

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"sort"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Status struct {
	ID         string    `json:"id"`
	Name       string    `json:"name"`
	Status     string    `json:"status"`
	ObservedAt time.Time `json:"observedAt"`
	LatencyMS  int       `json:"latencyMs"`
}

type Transition struct {
	Status         string    `json:"status"`
	PreviousStatus *string   `json:"previousStatus,omitempty"`
	ObservedAt     time.Time `json:"observedAt"`
	LatencyMS      int       `json:"latencyMs"`
	Message        string    `json:"message,omitempty"`
}

type Observation struct {
	ID         string
	Name       string
	Public     bool
	Status     string
	ObservedAt time.Time
	LatencyMS  int
	Message    string
}

var ErrNotFound = errors.New("service not found")

type SLO struct {
	ServiceID                   string    `json:"serviceId"`
	WindowStart                 time.Time `json:"windowStart"`
	WindowEnd                   time.Time `json:"windowEnd"`
	SampleCount                 int64     `json:"sampleCount"`
	GoodCount                   int64     `json:"goodCount"`
	AvailabilityPercent         float64   `json:"availabilityPercent"`
	ObjectivePercent            float64   `json:"objectivePercent"`
	ErrorBudgetRemainingPercent float64   `json:"errorBudgetRemainingPercent"`
	BurnRate                    float64   `json:"burnRate"`
	LatencyP50MS                float64   `json:"latencyP50Ms"`
	LatencyP95MS                float64   `json:"latencyP95Ms"`
	LatencyP99MS                float64   `json:"latencyP99Ms"`
}

type Reader interface {
	Ping(context.Context) error
	ListStatuses(context.Context) ([]Status, error)
	ListTransitions(context.Context, string, int) ([]Transition, error)
	ServiceSLO(context.Context, string, time.Time, time.Time, float64) (SLO, error)
}

func (s *Store) ServiceSLO(ctx context.Context, serviceID string, start, end time.Time, objective float64) (SLO, error) {
	result := SLO{ServiceID: serviceID, WindowStart: start, WindowEnd: end, ObjectivePercent: objective}
	err := s.pool.QueryRow(ctx, `
WITH visible_service AS (
    SELECT id FROM services WHERE id = $1 AND public = true
)
SELECT
    count(o.id),
    count(o.id) FILTER (WHERE o.status = 'operational'),
    COALESCE(percentile_cont(0.50) WITHIN GROUP (ORDER BY o.latency_ms), 0),
    COALESCE(percentile_cont(0.95) WITHIN GROUP (ORDER BY o.latency_ms), 0),
    COALESCE(percentile_cont(0.99) WITHIN GROUP (ORDER BY o.latency_ms), 0)
FROM visible_service AS s
LEFT JOIN probe_observations AS o
  ON o.service_id = s.id AND o.observed_at >= $2 AND o.observed_at < $3
GROUP BY s.id`, serviceID, start, end).Scan(
		&result.SampleCount, &result.GoodCount, &result.LatencyP50MS,
		&result.LatencyP95MS, &result.LatencyP99MS,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return SLO{}, ErrNotFound
	}
	if err != nil {
		return SLO{}, fmt.Errorf("query service SLO: %w", err)
	}
	if result.SampleCount == 0 {
		return result, nil
	}
	result.AvailabilityPercent = float64(result.GoodCount) / float64(result.SampleCount) * 100
	allowedBadFraction := 1 - objective/100
	badFraction := 1 - result.AvailabilityPercent/100
	result.BurnRate = badFraction / allowedBadFraction
	result.ErrorBudgetRemainingPercent = (allowedBadFraction - badFraction) / allowedBadFraction * 100
	return result, nil
}

func (s *Store) ListTransitions(ctx context.Context, serviceID string, limit int) ([]Transition, error) {
	rows, err := s.pool.Query(ctx, `
SELECT t.status, t.previous_status, t.observed_at, t.latency_ms, t.message
FROM status_transitions AS t
JOIN services AS s ON s.id = t.service_id
WHERE t.service_id = $1 AND s.public = true
ORDER BY t.observed_at DESC
LIMIT $2`, serviceID, limit)
	if err != nil {
		return nil, fmt.Errorf("query transitions: %w", err)
	}
	defer rows.Close()

	transitions, err := pgx.CollectRows(rows, pgx.RowToStructByPos[Transition])
	if err != nil {
		return nil, fmt.Errorf("collect transitions: %w", err)
	}
	return transitions, nil
}

type Store struct {
	pool *pgxpool.Pool
}

func Open(ctx context.Context, databaseURL string) (*Store, error) {
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("parse database configuration: %w", err)
	}
	config.MaxConns = 8
	config.MinConns = 1
	config.MaxConnLifetime = 30 * time.Minute
	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("open database pool: %w", err)
	}
	return &Store{pool: pool}, nil
}

func (s *Store) Close() { s.pool.Close() }

func (s *Store) Ping(ctx context.Context) error { return s.pool.Ping(ctx) }

func (s *Store) ListStatuses(ctx context.Context) ([]Status, error) {
	rows, err := s.pool.Query(ctx, `
SELECT s.id, s.display_name, c.status, c.observed_at, c.latency_ms
FROM services AS s
JOIN current_status AS c ON c.service_id = s.id
WHERE s.public = true
ORDER BY s.display_name`)
	if err != nil {
		return nil, fmt.Errorf("query status: %w", err)
	}
	defer rows.Close()

	statuses, err := pgx.CollectRows(rows, pgx.RowToStructByPos[Status])
	if err != nil {
		return nil, fmt.Errorf("collect status: %w", err)
	}
	return statuses, nil
}

func (s *Store) RecordObservation(ctx context.Context, observation Observation) (bool, error) {
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return false, fmt.Errorf("begin observation: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	if _, err = tx.Exec(ctx, `
INSERT INTO services (id, display_name, public) VALUES ($1, $2, $3)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, public = EXCLUDED.public`,
		observation.ID, observation.Name, observation.Public); err != nil {
		return false, fmt.Errorf("upsert service: %w", err)
	}

	var previous string
	err = tx.QueryRow(ctx, `SELECT status FROM current_status WHERE service_id = $1 FOR UPDATE`, observation.ID).Scan(&previous)
	changed := false
	if err != nil && err != pgx.ErrNoRows {
		return false, fmt.Errorf("read current status: %w", err)
	}
	if err == pgx.ErrNoRows || previous != observation.Status {
		changed = true
		var previousValue any
		if err != pgx.ErrNoRows {
			previousValue = previous
		}
		if _, err = tx.Exec(ctx, `
INSERT INTO status_transitions (service_id, previous_status, status, observed_at, latency_ms, message)
VALUES ($1, $2, $3, $4, $5, $6)`, observation.ID, previousValue, observation.Status,
			observation.ObservedAt, observation.LatencyMS, observation.Message); err != nil {
			return false, fmt.Errorf("insert transition: %w", err)
		}
	}

	if _, err = tx.Exec(ctx, `
INSERT INTO current_status (service_id, status, observed_at, latency_ms, message)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (service_id) DO UPDATE SET status = EXCLUDED.status,
observed_at = EXCLUDED.observed_at, latency_ms = EXCLUDED.latency_ms, message = EXCLUDED.message`,
		observation.ID, observation.Status, observation.ObservedAt, observation.LatencyMS,
		observation.Message); err != nil {
		return false, fmt.Errorf("upsert current status: %w", err)
	}
	if _, err = tx.Exec(ctx, `
INSERT INTO probe_observations (service_id, status, observed_at, latency_ms, message)
VALUES ($1, $2, $3, $4, $5)`, observation.ID, observation.Status,
		observation.ObservedAt, observation.LatencyMS, observation.Message); err != nil {
		return false, fmt.Errorf("insert probe observation: %w", err)
	}
	if err = tx.Commit(ctx); err != nil {
		return false, fmt.Errorf("commit observation: %w", err)
	}
	return changed, nil
}

func (s *Store) PruneObservations(ctx context.Context, before time.Time) (int64, error) {
	result, err := s.pool.Exec(ctx, `DELETE FROM probe_observations WHERE observed_at < $1`, before)
	if err != nil {
		return 0, fmt.Errorf("prune probe observations: %w", err)
	}
	return result.RowsAffected(), nil
}

func (s *Store) Migrate(ctx context.Context, migrations fs.FS) error {
	connection, err := s.pool.Acquire(ctx)
	if err != nil {
		return fmt.Errorf("acquire migration connection: %w", err)
	}
	defer connection.Release()
	if _, err = connection.Exec(ctx, `SELECT pg_advisory_lock(hashtext('homelab-sentinel-migrations'))`); err != nil {
		return fmt.Errorf("lock migrations: %w", err)
	}
	defer func() {
		_, _ = connection.Exec(context.Background(), `SELECT pg_advisory_unlock(hashtext('homelab-sentinel-migrations'))`)
	}()
	if _, err = connection.Exec(ctx, `CREATE TABLE IF NOT EXISTS schema_migrations (version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())`); err != nil {
		return fmt.Errorf("create migration ledger: %w", err)
	}
	entries, err := fs.ReadDir(migrations, ".")
	if err != nil {
		return fmt.Errorf("list migrations: %w", err)
	}
	sort.Slice(entries, func(i, j int) bool { return entries[i].Name() < entries[j].Name() })
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".sql") {
			continue
		}
		var applied bool
		if err = connection.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM schema_migrations WHERE version = $1)`, entry.Name()).Scan(&applied); err != nil {
			return fmt.Errorf("check migration %s: %w", entry.Name(), err)
		}
		if applied {
			continue
		}
		content, readErr := fs.ReadFile(migrations, entry.Name())
		if readErr != nil {
			return fmt.Errorf("read migration %s: %w", entry.Name(), readErr)
		}
		tx, beginErr := connection.Begin(ctx)
		if beginErr != nil {
			return fmt.Errorf("begin migration %s: %w", entry.Name(), beginErr)
		}
		if _, err = tx.Exec(ctx, string(content)); err == nil {
			_, err = tx.Exec(ctx, `INSERT INTO schema_migrations (version) VALUES ($1)`, entry.Name())
		}
		if err != nil {
			_ = tx.Rollback(ctx)
			return fmt.Errorf("apply migration %s: %w", entry.Name(), err)
		}
		if err = tx.Commit(ctx); err != nil {
			return fmt.Errorf("commit migration %s: %w", entry.Name(), err)
		}
	}
	return nil
}
