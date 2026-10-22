package probe

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"slices"
	"sync"
	"sync/atomic"
	"time"

	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/config"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/prometheus/client_golang/prometheus"
	"go.opentelemetry.io/otel"
)

type Recorder interface {
	RecordObservation(context.Context, database.Observation) (bool, error)
	PruneObservations(context.Context, time.Time) (int64, error)
}

type Worker struct {
	recorder    Recorder
	client      *http.Client
	targets     []config.Target
	interval    time.Duration
	concurrency int
	retention   time.Duration
	lastCycle   atomic.Int64
	up          *prometheus.GaugeVec
	duration    *prometheus.HistogramVec
	transitions *prometheus.CounterVec
	pruned      prometheus.Counter
}

func New(recorder Recorder, client *http.Client, targets []config.Target, interval time.Duration, concurrency int, retention time.Duration, registry *prometheus.Registry) *Worker {
	worker := &Worker{
		recorder: recorder, client: client, targets: targets, interval: interval, concurrency: concurrency, retention: retention,
		up:          prometheus.NewGaugeVec(prometheus.GaugeOpts{Name: "sentinel_probe_up", Help: "Whether the latest service probe succeeded."}, []string{"service"}),
		duration:    prometheus.NewHistogramVec(prometheus.HistogramOpts{Name: "sentinel_probe_duration_seconds", Help: "Service probe latency.", Buckets: prometheus.DefBuckets}, []string{"service"}),
		transitions: prometheus.NewCounterVec(prometheus.CounterOpts{Name: "sentinel_status_transitions_total", Help: "Recorded service health transitions."}, []string{"service", "status"}),
		pruned:      prometheus.NewCounter(prometheus.CounterOpts{Name: "sentinel_observations_pruned_total", Help: "Probe observations removed by retention maintenance."}),
	}
	registry.MustRegister(worker.up, worker.duration, worker.transitions, worker.pruned)
	return worker
}

func (w *Worker) Run(ctx context.Context) error {
	w.prune(ctx)
	w.runCycle(ctx)
	ticker := time.NewTicker(w.interval)
	defer ticker.Stop()
	maintenance := time.NewTicker(6 * time.Hour)
	defer maintenance.Stop()
	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			w.runCycle(ctx)
		case <-maintenance.C:
			w.prune(ctx)
		}
	}
}

func (w *Worker) prune(ctx context.Context) {
	deleted, err := w.recorder.PruneObservations(ctx, time.Now().UTC().Add(-w.retention))
	if err != nil {
		slog.ErrorContext(ctx, "prune observations", "error", err)
		return
	}
	w.pruned.Add(float64(deleted))
	if deleted > 0 {
		slog.InfoContext(ctx, "pruned observations", "count", deleted)
	}
}

func (w *Worker) runCycle(ctx context.Context) {
	semaphore := make(chan struct{}, w.concurrency)
	var group sync.WaitGroup
	for _, target := range w.targets {
		if ctx.Err() != nil {
			break
		}
		semaphore <- struct{}{}
		group.Add(1)
		go func(target config.Target) {
			defer group.Done()
			defer func() { <-semaphore }()
			w.probe(ctx, target)
		}(target)
	}
	group.Wait()
	if ctx.Err() == nil {
		w.lastCycle.Store(time.Now().UnixNano())
	}
}

func (w *Worker) Ready(maxAge time.Duration) bool {
	completed := w.lastCycle.Load()
	return completed != 0 && time.Since(time.Unix(0, completed)) <= maxAge
}

func (w *Worker) probe(ctx context.Context, target config.Target) {
	ctx, span := otel.Tracer("sentinel-worker").Start(ctx, "probe "+target.ID)
	defer span.End()
	started := time.Now()
	status, message := "operational", ""
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, target.URL, nil)
	if err == nil {
		request.Header.Set("User-Agent", "homelab-sentinel/1")
		var response *http.Response
		response, err = w.client.Do(request)
		if err == nil {
			_, _ = io.CopyN(io.Discard, response.Body, 4096)
			_ = response.Body.Close()
			status, message = classifyStatus(response.StatusCode, target.ExpectedStatuses)
		}
	}
	if err != nil {
		status, message = "down", "request failed"
	}
	duration := time.Since(started)
	up := 0.0
	if status == "operational" {
		up = 1
	}
	w.up.WithLabelValues(target.ID).Set(up)
	w.duration.WithLabelValues(target.ID).Observe(duration.Seconds())
	changed, recordErr := w.recorder.RecordObservation(ctx, database.Observation{
		ID: target.ID, Name: target.Name, Public: target.Public, Status: status,
		ObservedAt: time.Now().UTC(), LatencyMS: int(duration.Milliseconds()), Message: message,
	})
	if recordErr != nil {
		slog.ErrorContext(ctx, "record observation", "service", target.ID, "error", recordErr)
		return
	}
	if changed {
		w.transitions.WithLabelValues(target.ID, status).Inc()
		slog.InfoContext(ctx, "service status changed", "service", target.ID, "status", status)
	}
}

func classifyStatus(statusCode int, expected []int) (string, string) {
	if (len(expected) == 0 && statusCode >= 200 && statusCode < 300) || slices.Contains(expected, statusCode) {
		return "operational", ""
	}
	message := fmt.Sprintf("HTTP %d", statusCode)
	if statusCode >= 300 && statusCode < 500 {
		return "degraded", message
	}
	return "down", message
}
