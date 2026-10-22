package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/config"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/probe"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/telemetry"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	cfg, err := config.Load(true)
	if err != nil {
		slog.Error("load configuration", "error", err)
		os.Exit(1)
	}
	store, err := database.Open(ctx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("open database", "error", err)
		os.Exit(1)
	}
	defer store.Close()
	shutdownTelemetry, err := telemetry.Configure(ctx, "sentinel-worker", cfg.OTLPEndpoint)
	if err != nil {
		slog.Error("configure telemetry", "error", err)
		os.Exit(1)
	}
	defer func() { _ = shutdownTelemetry(context.Background()) }()
	registry := prometheus.NewRegistry()
	client := &http.Client{
		Timeout:   cfg.ProbeTimeout,
		Transport: otelhttp.NewTransport(http.DefaultTransport),
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	worker := probe.New(store, client, cfg.Targets, cfg.ProbeInterval, cfg.ProbeWorkers, cfg.ObservationRetention, registry)
	metricsMux := http.NewServeMux()
	metricsMux.Handle("GET /metrics", promhttp.HandlerFor(registry, promhttp.HandlerOpts{}))
	metricsMux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	metricsMux.HandleFunc("GET /readyz", func(w http.ResponseWriter, request *http.Request) {
		readyCtx, cancel := context.WithTimeout(request.Context(), 2*time.Second)
		defer cancel()
		if err := store.Ping(readyCtx); err != nil || !worker.Ready(2*cfg.ProbeInterval) {
			http.Error(w, "unavailable", http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	})
	metricsServer := &http.Server{
		Addr: cfg.MetricsAddr, Handler: metricsMux, ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout: 5 * time.Second, WriteTimeout: 10 * time.Second, IdleTimeout: 60 * time.Second,
	}
	go func() {
		if serveErr := metricsServer.ListenAndServe(); serveErr != nil && serveErr != http.ErrServerClosed {
			slog.Error("serve worker metrics", "error", serveErr)
			stop()
		}
	}()
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = metricsServer.Shutdown(shutdownCtx)
	}()
	if err := worker.Run(ctx); err != nil {
		slog.Error("run probe worker", "error", err)
		os.Exit(1)
	}
}
