package api

import (
	"context"
	"crypto/rand"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

var serviceIDPattern = regexp.MustCompile(`^[a-z][a-z0-9-]{0,62}$`)

//go:embed assets
var assets embed.FS

type Server struct {
	store    database.Reader
	requests *prometheus.CounterVec
}

func New(store database.Reader, registry *prometheus.Registry) http.Handler {
	server := &Server{
		store: store,
		requests: prometheus.NewCounterVec(prometheus.CounterOpts{
			Name: "sentinel_api_requests_total",
			Help: "Total Sentinel API requests by route and response class.",
		}, []string{"route", "class"}),
	}
	registry.MustRegister(server.requests)
	for _, route := range []string{"healthz", "readyz", "status", "summary", "history", "slo"} {
		for _, class := range []string{"2xx", "4xx", "5xx"} {
			server.requests.WithLabelValues(route, class).Add(0)
		}
	}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", server.health)
	mux.HandleFunc("GET /readyz", server.ready)
	mux.HandleFunc("GET /api/v1/status", server.status)
	mux.HandleFunc("GET /api/v1/summary", server.summary)
	mux.HandleFunc("GET /api/v1/services/{id}/history", server.history)
	mux.HandleFunc("GET /api/v1/services/{id}/slo", server.slo)
	mux.Handle("GET /metrics", promhttp.HandlerFor(registry, promhttp.HandlerOpts{}))
	assetFS, err := fs.Sub(assets, "assets")
	if err != nil {
		panic(err)
	}
	mux.Handle("GET /", http.FileServer(http.FS(assetFS)))
	handler := securityHeaders(otelhttp.NewHandler(mux, "sentinel-http"))
	return requestID(recoverPanics(accessLog(handler)))
}

func (s *Server) slo(w http.ResponseWriter, request *http.Request) {
	serviceID := request.PathValue("id")
	if !serviceIDPattern.MatchString(serviceID) {
		s.requests.WithLabelValues("slo", "4xx").Inc()
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid service id"})
		return
	}
	windows := map[string]time.Duration{
		"1h": time.Hour, "6h": 6 * time.Hour, "24h": 24 * time.Hour,
		"7d": 7 * 24 * time.Hour, "30d": 30 * 24 * time.Hour,
	}
	windowName := request.URL.Query().Get("window")
	if windowName == "" {
		windowName = "24h"
	}
	window, ok := windows[windowName]
	if !ok {
		s.requests.WithLabelValues("slo", "4xx").Inc()
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "window must be one of 1h, 6h, 24h, 7d, or 30d"})
		return
	}
	objective := 99.9
	if raw := request.URL.Query().Get("objective"); raw != "" {
		parsed, err := strconv.ParseFloat(raw, 64)
		if err != nil || parsed < 90 || parsed > 99.999 {
			s.requests.WithLabelValues("slo", "4xx").Inc()
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "objective must be between 90 and 99.999"})
			return
		}
		objective = parsed
	}
	end := time.Now().UTC()
	ctx, cancel := context.WithTimeout(request.Context(), 3*time.Second)
	defer cancel()
	result, err := s.store.ServiceSLO(ctx, serviceID, end.Add(-window), end, objective)
	if errors.Is(err, database.ErrNotFound) {
		s.requests.WithLabelValues("slo", "4xx").Inc()
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "service not found"})
		return
	}
	if err != nil {
		slog.ErrorContext(ctx, "calculate service SLO", "service", serviceID, "error", err)
		s.requests.WithLabelValues("slo", "5xx").Inc()
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "SLO unavailable"})
		return
	}
	s.requests.WithLabelValues("slo", "2xx").Inc()
	writeJSON(w, http.StatusOK, result)
}

func (s *Server) summary(w http.ResponseWriter, request *http.Request) {
	ctx, cancel := context.WithTimeout(request.Context(), 3*time.Second)
	defer cancel()
	statuses, err := s.store.ListStatuses(ctx)
	if err != nil {
		slog.ErrorContext(ctx, "summarize statuses", "error", err)
		s.requests.WithLabelValues("summary", "5xx").Inc()
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "summary unavailable"})
		return
	}
	counts := map[string]int{"operational": 0, "degraded": 0, "down": 0}
	overall := "operational"
	for _, service := range statuses {
		counts[service.Status]++
		if service.Status == "down" || (service.Status == "degraded" && overall == "operational") {
			overall = service.Status
		}
	}
	s.requests.WithLabelValues("summary", "2xx").Inc()
	writeJSON(w, http.StatusOK, map[string]any{
		"overall": overall, "counts": counts, "total": len(statuses), "generatedAt": time.Now().UTC(),
	})
}

func (s *Server) history(w http.ResponseWriter, request *http.Request) {
	serviceID := request.PathValue("id")
	if !serviceIDPattern.MatchString(serviceID) {
		s.requests.WithLabelValues("history", "4xx").Inc()
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid service id"})
		return
	}
	limit := 50
	if raw := request.URL.Query().Get("limit"); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > 200 {
			s.requests.WithLabelValues("history", "4xx").Inc()
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "limit must be between 1 and 200"})
			return
		}
		limit = parsed
	}
	ctx, cancel := context.WithTimeout(request.Context(), 3*time.Second)
	defer cancel()
	transitions, err := s.store.ListTransitions(ctx, serviceID, limit)
	if err != nil {
		slog.ErrorContext(ctx, "list transitions", "service", serviceID, "error", err)
		s.requests.WithLabelValues("history", "5xx").Inc()
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "history unavailable"})
		return
	}
	s.requests.WithLabelValues("history", "2xx").Inc()
	writeJSON(w, http.StatusOK, map[string]any{
		"serviceId": serviceID, "transitions": transitions, "generatedAt": time.Now().UTC(),
	})
}

func (s *Server) health(w http.ResponseWriter, _ *http.Request) {
	s.requests.WithLabelValues("healthz", "2xx").Inc()
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (s *Server) ready(w http.ResponseWriter, request *http.Request) {
	ctx, cancel := context.WithTimeout(request.Context(), 2*time.Second)
	defer cancel()
	if err := s.store.Ping(ctx); err != nil {
		s.requests.WithLabelValues("readyz", "5xx").Inc()
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "unavailable"})
		return
	}
	s.requests.WithLabelValues("readyz", "2xx").Inc()
	writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
}

func (s *Server) status(w http.ResponseWriter, request *http.Request) {
	ctx, cancel := context.WithTimeout(request.Context(), 3*time.Second)
	defer cancel()
	statuses, err := s.store.ListStatuses(ctx)
	if err != nil {
		slog.ErrorContext(ctx, "list statuses", "error", err)
		s.requests.WithLabelValues("status", "5xx").Inc()
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"error": "status unavailable"})
		return
	}
	s.requests.WithLabelValues("status", "2xx").Inc()
	writeJSON(w, http.StatusOK, map[string]any{"services": statuses, "generatedAt": time.Now().UTC()})
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(value); err != nil {
		slog.Error("encode response", "error", err)
	}
}

func securityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		w.Header().Set("Content-Security-Policy", "default-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'")
		w.Header().Set("Referrer-Policy", "no-referrer")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		next.ServeHTTP(w, request)
	})
}

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (w *responseWriter) WriteHeader(status int) {
	w.status = status
	w.ResponseWriter.WriteHeader(status)
}

func requestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		var value [16]byte
		if _, err := rand.Read(value[:]); err != nil {
			value = [16]byte{}
		}
		id := fmt.Sprintf("%x", value)
		w.Header().Set("X-Request-ID", id)
		next.ServeHTTP(w, request.WithContext(context.WithValue(request.Context(), requestIDKey{}, id)))
	})
}

type requestIDKey struct{}

func accessLog(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		started := time.Now()
		writer := &responseWriter{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(writer, request)
		slog.InfoContext(request.Context(), "http request",
			"request_id", request.Context().Value(requestIDKey{}),
			"method", request.Method, "path", request.URL.Path,
			"status", writer.status, "duration_ms", time.Since(started).Milliseconds())
	})
}

func recoverPanics(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, request *http.Request) {
		defer func() {
			if recovered := recover(); recovered != nil {
				slog.ErrorContext(request.Context(), "recovered request panic", "panic", recovered)
				writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "internal server error"})
			}
		}()
		next.ServeHTTP(w, request)
	})
}
