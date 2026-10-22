package main

import (
	"context"
	"flag"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	apihttp "github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/api"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/config"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/telemetry"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/migrations"
	"github.com/prometheus/client_golang/prometheus"
)

func main() {
	mode := flag.String("mode", "serve", "serve or migrate")
	flag.Parse()
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	cfg, err := config.Load(false)
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
	if *mode == "migrate" {
		if err := store.Migrate(ctx, migrations.Files); err != nil {
			slog.Error("migrate database", "error", err)
			os.Exit(1)
		}
		return
	}
	shutdownTelemetry, err := telemetry.Configure(ctx, "sentinel-api", cfg.OTLPEndpoint)
	if err != nil {
		slog.Error("configure telemetry", "error", err)
		os.Exit(1)
	}
	defer func() { _ = shutdownTelemetry(context.Background()) }()
	server := &http.Server{Addr: cfg.ListenAddr, Handler: apihttp.New(store, prometheus.NewRegistry()), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 10 * time.Second, WriteTimeout: 10 * time.Second, IdleTimeout: 60 * time.Second}
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_ = server.Shutdown(shutdownCtx)
	}()
	slog.Info("sentinel API listening", "address", cfg.ListenAddr)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		slog.Error("serve API", "error", err)
		os.Exit(1)
	}
}
