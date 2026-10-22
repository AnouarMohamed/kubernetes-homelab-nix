package probe

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"

	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/config"
	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/prometheus/client_golang/prometheus"
)

type memoryRecorder struct {
	mu           sync.Mutex
	observations []database.Observation
}

func (r *memoryRecorder) RecordObservation(_ context.Context, observation database.Observation) (bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.observations = append(r.observations, observation)
	return true, nil
}

func (r *memoryRecorder) PruneObservations(context.Context, time.Time) (int64, error) { return 0, nil }

func TestProbeClassifiesServerFailure(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusBadGateway) }))
	defer server.Close()
	recorder := &memoryRecorder{}
	worker := New(recorder, server.Client(), []config.Target{{ID: "site", Name: "Site", URL: server.URL, Public: true}}, time.Minute, 2, 30*24*time.Hour, prometheus.NewRegistry())
	worker.runCycle(context.Background())
	if len(recorder.observations) != 1 || recorder.observations[0].Status != "down" {
		t.Fatalf("unexpected observations: %#v", recorder.observations)
	}
}

func TestClassifyStatusContracts(t *testing.T) {
	tests := []struct {
		name     string
		code     int
		expected []int
		want     string
	}{
		{name: "default success", code: 204, want: "operational"},
		{name: "redirect degraded", code: 302, want: "degraded"},
		{name: "client failure degraded", code: 404, want: "degraded"},
		{name: "server failure down", code: 503, want: "down"},
		{name: "explicit redirect success", code: 302, expected: []int{302}, want: "operational"},
		{name: "unexpected success", code: 200, expected: []int{204}, want: "down"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			got, _ := classifyStatus(test.code, test.expected)
			if got != test.want {
				t.Fatalf("classifyStatus(%d, %v) = %q, want %q", test.code, test.expected, got, test.want)
			}
		})
	}
}

func TestWorkerReadinessRequiresFreshCompletedCycle(t *testing.T) {
	recorder := &memoryRecorder{}
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusNoContent) }))
	defer server.Close()
	worker := New(recorder, server.Client(), []config.Target{{ID: "site", Name: "Site", URL: server.URL}}, time.Minute, 1, 30*24*time.Hour, prometheus.NewRegistry())
	if worker.Ready(time.Minute) {
		t.Fatal("worker was ready before its first cycle")
	}
	worker.runCycle(context.Background())
	if !worker.Ready(time.Minute) {
		t.Fatal("worker was not ready after a successful cycle")
	}
}
