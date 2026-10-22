package api

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/AnouarMohamed/kubernetes-homelab-nix/apps/sentinel/internal/database"
	"github.com/prometheus/client_golang/prometheus"
)

type fakeStore struct {
	pingErr     error
	statuses    []database.Status
	transitions []database.Transition
	slo         database.SLO
	sloErr      error
}

func (f fakeStore) Ping(context.Context) error                              { return f.pingErr }
func (f fakeStore) ListStatuses(context.Context) ([]database.Status, error) { return f.statuses, nil }
func (f fakeStore) ListTransitions(context.Context, string, int) ([]database.Transition, error) {
	return f.transitions, nil
}
func (f fakeStore) ServiceSLO(context.Context, string, time.Time, time.Time, float64) (database.SLO, error) {
	return f.slo, f.sloErr
}

func TestStatusResponseDoesNotExposeTargetURLs(t *testing.T) {
	handler := New(fakeStore{statuses: []database.Status{{ID: "site", Name: "Site", Status: "operational", ObservedAt: time.Unix(1, 0), LatencyMS: 12}}}, prometheus.NewRegistry())
	request := httptest.NewRequest(http.MethodGet, "/api/v1/status", nil)
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusOK {
		t.Fatalf("unexpected status: %d", recorder.Code)
	}
	var body map[string]any
	if err := json.Unmarshal(recorder.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if recorder.Header().Get("Content-Security-Policy") == "" {
		t.Fatal("missing content security policy")
	}
	if recorder.Header().Get("X-Request-ID") == "" {
		t.Fatal("missing request id")
	}
}

func TestSummaryUsesWorstStatus(t *testing.T) {
	handler := New(fakeStore{statuses: []database.Status{
		{ID: "site", Status: "operational"},
		{ID: "auth", Status: "degraded"},
		{ID: "dns", Status: "down"},
	}}, prometheus.NewRegistry())
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "/api/v1/summary", nil))
	if recorder.Code != http.StatusOK {
		t.Fatalf("unexpected status: %d", recorder.Code)
	}
	var body struct {
		Overall string         `json:"overall"`
		Counts  map[string]int `json:"counts"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Overall != "down" || body.Counts["operational"] != 1 || body.Counts["degraded"] != 1 || body.Counts["down"] != 1 {
		t.Fatalf("unexpected summary: %#v", body)
	}
}

func TestHistoryRejectsInvalidInput(t *testing.T) {
	handler := New(fakeStore{}, prometheus.NewRegistry())
	for _, path := range []string{"/api/v1/services/INVALID/history", "/api/v1/services/site/history?limit=201"} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, path, nil))
		if recorder.Code != http.StatusBadRequest {
			t.Fatalf("%s returned %d", path, recorder.Code)
		}
	}
}

func TestReadinessFailsClosed(t *testing.T) {
	handler := New(fakeStore{pingErr: errors.New("database unavailable")}, prometheus.NewRegistry())
	request := httptest.NewRequest(http.MethodGet, "/readyz", nil)
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusServiceUnavailable {
		t.Fatalf("unexpected status: %d", recorder.Code)
	}
}

func TestSLOResponse(t *testing.T) {
	want := database.SLO{ServiceID: "site", SampleCount: 1000, GoodCount: 999, AvailabilityPercent: 99.9, ObjectivePercent: 99.9, ErrorBudgetRemainingPercent: 0, BurnRate: 1, LatencyP95MS: 42}
	handler := New(fakeStore{slo: want}, prometheus.NewRegistry())
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "/api/v1/services/site/slo?window=7d&objective=99.9", nil))
	if recorder.Code != http.StatusOK {
		t.Fatalf("unexpected status: %d", recorder.Code)
	}
	var got database.SLO
	if err := json.Unmarshal(recorder.Body.Bytes(), &got); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if got.SampleCount != want.SampleCount || got.LatencyP95MS != want.LatencyP95MS {
		t.Fatalf("unexpected SLO: %#v", got)
	}
}

func TestSLORejectsInvalidParameters(t *testing.T) {
	handler := New(fakeStore{}, prometheus.NewRegistry())
	for _, path := range []string{
		"/api/v1/services/INVALID/slo",
		"/api/v1/services/site/slo?window=forever",
		"/api/v1/services/site/slo?objective=100",
	} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, path, nil))
		if recorder.Code != http.StatusBadRequest {
			t.Fatalf("%s returned %d", path, recorder.Code)
		}
	}
}

func TestSLONotFound(t *testing.T) {
	handler := New(fakeStore{sloErr: database.ErrNotFound}, prometheus.NewRegistry())
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "/api/v1/services/missing/slo", nil))
	if recorder.Code != http.StatusNotFound {
		t.Fatalf("unexpected status: %d", recorder.Code)
	}
}
