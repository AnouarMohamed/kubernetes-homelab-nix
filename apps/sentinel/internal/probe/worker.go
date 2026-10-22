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
}

type Worker struct {
	recorder    Recorder
	client      *http.Client
	targets     []config.Target
	interval    time.Duration
	concurrency int
	lastCycle   atomic.Int64
	up          *prometheus.GaugeVec
	duration    *prometheus.HistogramVec
	transitions *prometheus.CounterVec
}

func New(recorder Recorder, client *http.Client, targets []config.Target, interval time.Duration, concurrency int, registry *prometheus.Registry) *Worker {
	worker := &Worker{
		recorder: recorder, client: client, targets: targets, interval: interval, concurrency: concurrency,
		up:          prometheus.NewGaugeVec(prometheus.GaugeOpts{Name: "sentinel_probe_up", Help: "Whether the latest service probe succeeded."}, []string{"service"}),
		duration:    prometheus.NewHistogramVec(prometheus.HistogramOpts{Name: "sentinel_probe_duration_seconds", Help: "Service probe latency.", Buckets: prometheus.DefBuckets}, []string{"service"}),
		transitions: prometheus.NewCounterVec(prometheus.CounterOpts{Name: "sentinel_status_transitions_total", Help: "Recorded service health transitions."}, []string{"service", "status"}),
	}
	registry.MustRegister(worker.up, worker.duration, worker.transitions)
	return worker
}

func (w *Worker) Run(ctx context.Context) error {
	w.runCycle(ctx)
	ticker := time.NewTicker(w.interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			w.runCycle(ctx)
		}
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
