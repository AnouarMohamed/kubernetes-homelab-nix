# One-time conversion from:
# - /home/anouar/kubernetes-homelab/observability/bootstrap/create-monitoring-namespace.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/alert-on-platform-failures.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/measure-platform-slo.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/monitor-platform-components.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/provide-platform-dashboards.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/restrict-monitoring-network.yaml
# - /home/anouar/kubernetes-homelab/observability/resources/restrict-monitoring-network.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/configure-alertmanager-routing.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/connect-monitoring-to-openbao.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/materialize-alertmanager-destination.yaml
# - /home/anouar/kubernetes-homelab/observability/runtime-secrets/materialize-grafana-administrator.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/materialize-argocd-oidc-secret.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/materialize-notification-destination.yaml
# - /home/anouar/kubernetes-homelab/observability/argocd-notifications/materialize-notification-destination.yaml
[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "monitoring";
        "app.kubernetes.io/component" = "observability";
        "app.kubernetes.io/part-of" = "homelab";
        "runtime-secrets.homelab.dev/openbao-ca" = "true";
        "pod-security.kubernetes.io/enforce" = "privileged";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "PrometheusRule";
    metadata = {
      name = "homelab-platform-alerts";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "homelab-platform-alerts";
        "app.kubernetes.io/component" = "alerting";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      groups = [
        {
          name = "homelab.availability";
          rules = [
            {
              alert = "Watchdog";
              expr = "vector(1)";
              labels = {
                severity = "none";
              };
              annotations = {
                summary = "Alert pipeline heartbeat";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#watchdog";
              };
            }
            {
              alert = "NodeDown";
              expr = "up{job=~\".*node-exporter.*\"} == 0";
              for = "5m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Node exporter target is unavailable";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#node-down";
              };
            }
            {
              alert = "EtcdLeaderChanges";
              expr = "increase(etcd_server_leader_changes_seen_total[15m]) > 2";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "Embedded etcd leadership is unstable";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#etcd-leader-changes";
              };
            }
            {
              alert = "NodeDiskPressure";
              expr = "kube_node_status_condition{condition=\"DiskPressure\",status=\"true\"} == 1";
              for = "10m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "A node reports disk pressure";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#disk-pressure";
              };
            }
            {
              alert = "CertificateExpiringSoon";
              expr = "certmanager_certificate_expiration_timestamp_seconds - time() < 1209600";
              for = "1h";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A managed certificate expires within fourteen days";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#certificate-expiry";
              };
            }
            {
              alert = "ArgoApplicationOutOfSync";
              expr = "argocd_app_info{sync_status!=\"Synced\"} == 1";
              for = "15m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "An Argo CD application remains out of sync";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#argo-cd-out-of-sync";
              };
            }
            {
              alert = "BackupJobFailed";
              expr = "max by (namespace, job_name) (kube_job_status_failed{job_name=~\".*(backup|snapshot).*\"}) > 0 and on(namespace, job_name) (time() - kube_job_created < 3600)";
              for = "10m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "A backup or snapshot job failed";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#backup-failure";
              };
            }
            {
              alert = "LonghornVolumeDegraded";
              expr = "longhorn_volume_robustness{state=~\"degraded|faulted\"} == 1";
              for = "10m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "A Longhorn volume is degraded";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#longhorn-degraded";
              };
            }
            {
              alert = "ContainerRestartBurst";
              expr = "increase(kube_pod_container_status_restarts_total[15m]) > 3";
              for = "5m";
              labels = {
                severity = "warning";
              };
              annotations = {
                summary = "A container restarted repeatedly";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#container-restarts";
              };
            }
            {
              alert = "KubernetesApiHighLatency";
              expr = "histogram_quantile(0.99, sum by (le) (rate(apiserver_request_duration_seconds_bucket{verb!~\"WATCH|WATCHLIST\"}[5m]))) > 1";
              for = "10m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Kubernetes API p99 latency exceeds one second";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#api-latency";
              };
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "sloth.slok.dev/v1";
    kind = "PrometheusServiceLevel";
    metadata = {
      name = "prometheus-api";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "prometheus-api-slo";
        "app.kubernetes.io/component" = "slo";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      service = "prometheus-api";
      labels = {
        owner = "platform";
      };
      slos = [
        {
          name = "availability";
          objective = 99.9;
          description = "Prometheus API requests succeed over a rolling thirty-day period.";
          sli = {
            events = {
              errorQuery = "sum(rate(prometheus_http_requests_total{code=~\"5..\"}[{{.window}}]))";
              totalQuery = "sum(rate(prometheus_http_requests_total[{{.window}}]))";
            };
          };
          alerting = {
            name = "PrometheusApiAvailabilityBudgetBurn";
            labels = {
              severity = "critical";
            };
            annotations = {
              runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-platform-alerts.md#slo-budget-burn";
            };
          };
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "ServiceMonitor";
    metadata = {
      name = "cilium";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      namespaceSelector = {
        matchNames = [
          "kube-system"
        ];
      };
      selector = {
        matchExpressions = [
          {
            key = "app.kubernetes.io/name";
            operator = "In";
            values = [
              "cilium-agent"
              "cilium-envoy"
              "cilium-operator"
              "hubble"
              "hubble-relay"
            ];
          }
        ];
      };
      endpoints = [
        {
          port = "metrics";
          interval = "30s";
        }
        {
          port = "hubble-metrics";
          interval = "30s";
        }
        {
          port = "envoy-metrics";
          interval = "30s";
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "ServiceMonitor";
    metadata = {
      name = "argocd";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      namespaceSelector = {
        matchNames = [
          "argocd"
        ];
      };
      selector = {
        matchExpressions = [
          {
            key = "app.kubernetes.io/name";
            operator = "In";
            values = [
              "argocd-metrics"
              "argocd-applicationset-controller"
              "argocd-repo-server-metrics"
              "argocd-server-metrics"
            ];
          }
        ];
      };
      endpoints = [
        {
          port = "http-metrics";
          interval = "30s";
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "ServiceMonitor";
    metadata = {
      name = "longhorn";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      namespaceSelector = {
        matchNames = [
          "longhorn-system"
        ];
      };
      selector = {
        matchLabels = {
          app = "longhorn-manager";
        };
      };
      endpoints = [
        {
          port = "manager";
          path = "/metrics";
          interval = "30s";
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "ServiceMonitor";
    metadata = {
      name = "openbao";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      namespaceSelector = {
        matchNames = [
          "openbao"
        ];
      };
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "openbao";
        };
      };
      endpoints = [
        {
          port = "https";
          scheme = "https";
          path = "/v1/sys/metrics";
          params = {
            format = [
              "prometheus"
            ];
          };
          tlsConfig = {
            serverName = "openbao.openbao.svc";
            ca = {
              secret = {
                name = "openbao-server-tls";
                key = "ca.crt";
              };
            };
          };
          interval = "30s";
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "PodMonitor";
    metadata = {
      name = "platform-controllers";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      namespaceSelector = {
        matchNames = [
          "cert-manager"
          "cnpg-system"
          "external-dns"
          "external-secrets"
          "velero"
        ];
      };
      selector = {
        matchExpressions = [
          {
            key = "app.kubernetes.io/name";
            operator = "Exists";
          }
        ];
      };
      podMetricsEndpoints = [
        {
          port = "metrics";
          interval = "30s";
        }
        {
          port = "http-metrics";
          interval = "30s";
        }
        {
          port = "http-monitoring";
          interval = "30s";
        }
      ];
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "Probe";
    metadata = {
      name = "platform-health";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "platform-components";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "observability";
        release = "monitoring";
      };
    };
    spec = {
      interval = "30s";
      module = "http_2xx";
      prober = {
        url = "blackbox-prometheus-blackbox-exporter.monitoring.svc:9115";
      };
      targets = {
        staticConfig = {
          static = [
            "http://monitoring-kube-prometheus-prometheus.monitoring.svc:9090/-/healthy"
            "http://loki.monitoring.svc:3100/ready"
            "http://tempo.monitoring.svc:3200/ready"
          ];
        };
      };
    };
  }
  {
    apiVersion = "v1";
    kind = "ConfigMap";
    metadata = {
      name = "homelab-platform-dashboards";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "homelab-platform-dashboards";
        "app.kubernetes.io/component" = "dashboards";
        "app.kubernetes.io/part-of" = "observability";
        grafana_dashboard = "1";
      };
    };
    data = {
      "overview.json" =
        "{\n  \"annotations\": {\n    \"list\": [\n      {\n        \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n        \"enable\": true,\n        \"expr\": \"ALERTS{alertstate=\\\"firing\\\",severity=~\\\"warning|critical\\\"}\",\n        \"iconColor\": \"red\",\n        \"name\": \"Firing alerts\",\n        \"tagKeys\": \"alertname,severity\",\n        \"textFormat\": \"{{alertname}}\"\n      }\n    ]\n  },\n  \"description\": \"Start here during validation or an incident. Current user impact is followed by delivery, platform pressure, and recovery risk.\",\n  \"editable\": false,\n  \"links\": [\n    {\n      \"asDropdown\": true,\n      \"icon\": \"external link\",\n      \"includeVars\": true,\n      \"keepTime\": true,\n      \"tags\": [\"homelab\", \"drilldown\"],\n      \"title\": \"Open a drill-down\",\n      \"type\": \"dashboards\"\n    }\n  ],\n  \"panels\": [\n    {\n      \"collapsed\": false,\n      \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0},\n      \"id\": 1,\n      \"panels\": [],\n      \"title\": \"Current user impact\",\n      \"type\": \"row\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Percentage of selected Sentinel probes whose latest result is healthy.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"decimals\": 1,\n          \"max\": 100,\n          \"min\": 0,\n          \"noValue\": \"Unknown\",\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"orange\", \"value\": 99}, {\"color\": \"green\", \"value\": 100}]},\n          \"unit\": \"percent\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 0, \"y\": 1},\n      \"id\": 2,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"100 * avg(sentinel_probe_up)\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Selected services healthy\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Share of Sentinel API requests returning a server error over five minutes.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"decimals\": 2,\n          \"max\": 100,\n          \"min\": 0,\n          \"noValue\": \"Unknown\",\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 5}]},\n          \"unit\": \"percent\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 6, \"y\": 1},\n      \"id\": 3,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"100 * sum(rate(sentinel_api_requests_total{class=\\\"5xx\\\"}[5m])) / clamp_min(sum(rate(sentinel_api_requests_total[5m])), 0.001)\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Sentinel API 5xx\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Critical alerts currently firing. Open Alertmanager before investigating lower-priority signals.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"decimals\": 0,\n          \"noValue\": \"Unknown\",\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]},\n          \"unit\": \"short\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 12, \"y\": 1},\n      \"id\": 4,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"count(ALERTS{alertstate=\\\"firing\\\",severity=\\\"critical\\\"}) or vector(0)\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Critical alerts firing\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"The fixed three-node embedded-etcd cluster requires all three nodes for full redundancy.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"decimals\": 0,\n          \"max\": 3,\n          \"min\": 0,\n          \"noValue\": \"Unknown\",\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"orange\", \"value\": 2}, {\"color\": \"green\", \"value\": 3}]},\n          \"unit\": \"short\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 18, \"y\": 1},\n      \"id\": 5,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"sum(kube_node_status_condition{condition=\\\"Ready\\\",status=\\\"true\\\"})\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Nodes ready of 3\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Latest probe result per selected service. A drop to zero is direct user-impact evidence.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineInterpolation\": \"stepAfter\", \"lineWidth\": 2, \"showPoints\": \"never\"},\n          \"max\": 1,\n          \"min\": 0,\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"green\", \"value\": 1}]},\n          \"unit\": \"bool_on_off\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 0, \"y\": 5},\n      \"id\": 6,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"sentinel_probe_up\", \"legendFormat\": \"{{service}}\", \"refId\": \"A\"}],\n      \"title\": \"Selected service availability\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Ninety-fifth percentile probe latency by service over five minutes.\",\n      \"fieldConfig\": {\n        \"defaults\": {\n          \"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 8, \"lineWidth\": 2, \"showPoints\": \"never\"},\n          \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.5}, {\"color\": \"red\", \"value\": 1}]},\n          \"unit\": \"s\"\n        },\n        \"overrides\": []\n      },\n      \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 12, \"y\": 5},\n      \"id\": 7,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"histogram_quantile(0.95, sum by (le, service) (rate(sentinel_probe_duration_seconds_bucket[5m])))\", \"legendFormat\": \"{{service}}\", \"refId\": \"A\"}],\n      \"title\": \"Probe latency p95\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"collapsed\": false,\n      \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 12},\n      \"id\": 8,\n      \"panels\": [],\n      \"title\": \"Change and delivery\",\n      \"type\": \"row\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Applications whose Argo CD health is not Healthy.\",\n      \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 3}]}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 0, \"y\": 13},\n      \"id\": 9,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"count(argocd_app_info{health_status!=\\\"Healthy\\\"}) or (0 * count(argocd_app_info))\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Unhealthy Argo CD apps\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Applications whose live state differs from Git for longer than the alert grace period.\",\n      \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 6, \"y\": 13},\n      \"id\": 10,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"count(argocd_app_info{sync_status!=\\\"Synced\\\"}) or (0 * count(argocd_app_info))\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Out-of-sync Argo CD apps\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Container restarts in the last fifteen minutes. Bursts often explain fresh degradation.\",\n      \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 3}, {\"color\": \"red\", \"value\": 10}]}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 12, \"y\": 13},\n      \"id\": 11,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"sum(increase(kube_pod_container_status_restarts_total[15m]))\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Container restarts in 15m\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Shortest remaining lifetime across certificates managed by cert-manager.\",\n      \"fieldConfig\": {\"defaults\": {\"decimals\": 1, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"orange\", \"value\": 14}, {\"color\": \"green\", \"value\": 30}]}, \"unit\": \"d\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 18, \"y\": 13},\n      \"id\": 12,\n      \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"min((certmanager_certificate_expiration_timestamp_seconds > 0) - time()) / 86400\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Shortest certificate lifetime\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Argo CD application health distribution. Use this to identify whether degradation is isolated or platform-wide.\",\n      \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 10, \"lineWidth\": 2, \"showPoints\": \"never\"}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 0, \"y\": 17},\n      \"id\": 13,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"sum by (health_status) (argocd_app_info)\", \"legendFormat\": \"{{health_status}}\", \"refId\": \"A\"}],\n      \"title\": \"Application health over time\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Top workloads by restart events in each rolling fifteen-minute window. Zero-event workloads are omitted.\",\n      \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"bars\", \"fillOpacity\": 30, \"lineWidth\": 1, \"showPoints\": \"never\"}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 12, \"y\": 17},\n      \"id\": 14,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"topk(8, sum by (namespace, pod) (increase(kube_pod_container_status_restarts_total[15m])) > 0)\", \"legendFormat\": \"{{namespace}} / {{pod}}\", \"refId\": \"A\"}],\n      \"title\": \"Recent workload restarts\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"collapsed\": true,\n      \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 24},\n      \"id\": 15,\n      \"panels\": [\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Mean non-idle CPU by node.\",\n          \"fieldConfig\": {\"defaults\": {\"max\": 100, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 75}, {\"color\": \"red\", \"value\": 90}]}, \"unit\": \"percent\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 8, \"x\": 0, \"y\": 25},\n          \"id\": 16,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\\\"idle\\\"}[5m])))\", \"legendFormat\": \"{{instance}}\", \"refId\": \"A\"}],\n          \"title\": \"Node CPU used\",\n          \"type\": \"timeseries\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Memory unavailable to workloads by node.\",\n          \"fieldConfig\": {\"defaults\": {\"max\": 100, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 80}, {\"color\": \"red\", \"value\": 90}]}, \"unit\": \"percent\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 8, \"x\": 8, \"y\": 25},\n          \"id\": 17,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)\", \"legendFormat\": \"{{instance}}\", \"refId\": \"A\"}],\n          \"title\": \"Node memory used\",\n          \"type\": \"timeseries\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Lowest free-space percentage on persistent local filesystems.\",\n          \"fieldConfig\": {\"defaults\": {\"max\": 100, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"orange\", \"value\": 15}, {\"color\": \"green\", \"value\": 25}]}, \"unit\": \"percent\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 8, \"x\": 16, \"y\": 25},\n          \"id\": 18,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"min\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"100 * node_filesystem_avail_bytes{fstype!~\\\"tmpfs|overlay|squashfs\\\",mountpoint!~\\\"/run.*\\\"} / node_filesystem_size_bytes{fstype!~\\\"tmpfs|overlay|squashfs\\\",mountpoint!~\\\"/run.*\\\"}\", \"legendFormat\": \"{{instance}} {{mountpoint}}\", \"refId\": \"A\"}],\n          \"title\": \"Filesystem headroom\",\n          \"type\": \"timeseries\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Policy-denied traffic reported by Hubble, grouped by reason.\",\n          \"fieldConfig\": {\"defaults\": {\"unit\": \"ops\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 0, \"y\": 32},\n          \"id\": 19,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"sum\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"sum by (reason) (rate(hubble_drop_total{reason=\\\"POLICY_DENIED\\\"}[5m]))\", \"legendFormat\": \"{{reason}}\", \"refId\": \"A\"}],\n          \"title\": \"Policy-denied network flows\",\n          \"type\": \"timeseries\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Pods unable to schedule or complete. Sustained pending pods indicate capacity or placement pressure.\",\n          \"fieldConfig\": {\"defaults\": {\"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 12, \"y\": 32},\n          \"id\": 20,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"sum by (phase) (kube_pod_status_phase{phase=~\\\"Pending|Failed|Unknown\\\"})\", \"legendFormat\": \"{{phase}}\", \"refId\": \"A\"}],\n          \"title\": \"Non-running workload pressure\",\n          \"type\": \"timeseries\"\n        }\n      ],\n      \"title\": \"Compute and network pressure\",\n      \"type\": \"row\"\n    },\n    {\n      \"collapsed\": true,\n      \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 25},\n      \"id\": 21,\n      \"panels\": [\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Longhorn volumes reporting degraded robustness.\",\n          \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 0, \"y\": 26},\n          \"id\": 22,\n          \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n          \"targets\": [{\"expr\": \"count(longhorn_volume_robustness{state=~\\\"degraded|faulted\\\"} == 1) or (0 * count(longhorn_volume_robustness{state=\\\"healthy\\\"}))\", \"instant\": true, \"refId\": \"A\"}],\n          \"title\": \"Degraded Longhorn volumes\",\n          \"type\": \"stat\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"CloudNativePG collectors currently reporting unhealthy.\",\n          \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 6, \"y\": 26},\n          \"id\": 23,\n          \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n          \"targets\": [{\"expr\": \"count(cnpg_collector_up == 0) or (0 * count(cnpg_collector_up))\", \"instant\": true, \"refId\": \"A\"}],\n          \"title\": \"Unhealthy PostgreSQL collectors\",\n          \"type\": \"stat\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Velero schedules whose most recent backup did not complete successfully.\",\n          \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 12, \"y\": 26},\n          \"id\": 24,\n          \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n          \"targets\": [{\"expr\": \"sum(velero_backup_last_status{schedule!=\\\"\\\"} != bool 1)\", \"instant\": true, \"refId\": \"A\"}],\n          \"title\": \"Unsuccessful Velero schedules\",\n          \"type\": \"stat\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Embedded-etcd members that do not currently observe a leader.\",\n          \"fieldConfig\": {\"defaults\": {\"decimals\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 4, \"w\": 6, \"x\": 18, \"y\": 26},\n          \"id\": 25,\n          \"options\": {\"colorMode\": \"value\", \"graphMode\": \"none\", \"justifyMode\": \"auto\", \"textMode\": \"auto\"},\n          \"targets\": [{\"expr\": \"count(etcd_server_has_leader == 0) or vector(0)\", \"instant\": true, \"refId\": \"A\"}],\n          \"title\": \"etcd members without leader\",\n          \"type\": \"stat\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Maximum PostgreSQL replication lag by instance.\",\n          \"fieldConfig\": {\"defaults\": {\"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 5}, {\"color\": \"red\", \"value\": 30}]}, \"unit\": \"s\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 0, \"y\": 30},\n          \"id\": 26,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"max by (namespace, pod) (cnpg_pg_replication_lag)\", \"legendFormat\": \"{{namespace}} / {{pod}}\", \"refId\": \"A\"}],\n          \"title\": \"PostgreSQL replication lag\",\n          \"type\": \"timeseries\"\n        },\n        {\n          \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n          \"description\": \"Recent etcd leader changes by member. Repeated changes threaten control-plane stability.\",\n          \"fieldConfig\": {\"defaults\": {\"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 3}]}, \"unit\": \"short\"}, \"overrides\": []},\n          \"gridPos\": {\"h\": 7, \"w\": 12, \"x\": 12, \"y\": 30},\n          \"id\": 27,\n          \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}},\n          \"targets\": [{\"expr\": \"increase(etcd_server_leader_changes_seen_total[1h])\", \"legendFormat\": \"{{instance}}\", \"refId\": \"A\"}],\n          \"title\": \"etcd leader changes in 1h\",\n          \"type\": \"timeseries\"\n        }\n      ],\n      \"title\": \"Data protection and control plane\",\n      \"type\": \"row\"\n    }\n  ],\n  \"refresh\": \"30s\",\n  \"schemaVersion\": 42,\n  \"tags\": [\"homelab\", \"overview\"],\n  \"time\": {\"from\": \"now-6h\", \"to\": \"now\"},\n  \"timepicker\": {\"refresh_intervals\": [\"30s\", \"1m\", \"5m\"], \"time_options\": [\"1h\", \"6h\", \"24h\", \"2d\", \"7d\"]},\n  \"timezone\": \"browser\",\n  \"title\": \"Homelab / Operations overview\",\n  \"uid\": \"homelab-overview\",\n  \"version\": 2\n}";
      "homelab-nodes.json" =
        "{\n  \"annotations\": {\"list\": []},\n  \"description\": \"Fleet readiness and resource pressure across the three schedulable k3s servers.\",\n  \"panels\": [\n    {\n      \"collapsed\": false,\n      \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0},\n      \"id\": 1,\n      \"panels\": [],\n      \"title\": \"Fleet posture\",\n      \"type\": \"row\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Ready nodes out of the fixed three-server control-plane and worker fleet.\",\n      \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"green\", \"value\": 3}]}, \"unit\": \"short\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 0, \"y\": 1},\n      \"id\": 2,\n      \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"sum(kube_node_status_condition{condition=\\\"Ready\\\",status=\\\"true\\\"} == 1)\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Nodes ready (target 3)\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Average non-idle CPU use. Sustained pressure above 85% threatens scheduling and control-plane work.\",\n      \"fieldConfig\": {\"defaults\": {\"max\": 1, \"min\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.7}, {\"color\": \"red\", \"value\": 0.85}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 6, \"y\": 1},\n      \"id\": 3,\n      \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"1 - avg(rate(node_cpu_seconds_total{mode=\\\"idle\\\"}[5m]))\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Fleet CPU used\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Memory consumed after reclaimable cache is excluded across the fleet.\",\n      \"fieldConfig\": {\"defaults\": {\"max\": 1, \"min\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.75}, {\"color\": \"red\", \"value\": 0.9}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 12, \"y\": 1},\n      \"id\": 4,\n      \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"1 - sum(node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes)\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Fleet memory used\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Highest root-filesystem utilization on any node.\",\n      \"fieldConfig\": {\"defaults\": {\"max\": 1, \"min\": 0, \"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.75}, {\"color\": \"red\", \"value\": 0.9}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 18, \"y\": 1},\n      \"id\": 5,\n      \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"},\n      \"targets\": [{\"expr\": \"max(1 - node_filesystem_avail_bytes{mountpoint=\\\"/\\\",fstype!~\\\"tmpfs|overlay\\\"} / node_filesystem_size_bytes{mountpoint=\\\"/\\\",fstype!~\\\"tmpfs|overlay\\\"})\", \"instant\": true, \"refId\": \"A\"}],\n      \"title\": \"Most-used root disk\",\n      \"type\": \"stat\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Non-idle CPU use by node, useful for spotting an imbalanced scheduler or noisy workload.\",\n      \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"max\": 1, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.7}, {\"color\": \"red\", \"value\": 0.85}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 0, \"y\": 6},\n      \"id\": 6,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"(1 - avg by(instance) (rate(node_cpu_seconds_total{mode=\\\"idle\\\"}[5m]))) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:9100\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}],\n      \"title\": \"CPU pressure by node\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Working memory by node after available memory is removed from total capacity.\",\n      \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"max\": 1, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.75}, {\"color\": \"red\", \"value\": 0.9}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 8, \"y\": 6},\n      \"id\": 7,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:9100\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}],\n      \"title\": \"Memory pressure by node\",\n      \"type\": \"timeseries\"\n    },\n    {\n      \"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"},\n      \"description\": \"Root-filesystem utilization by node. Longhorn capacity is tracked separately.\",\n      \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"max\": 1, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.75}, {\"color\": \"red\", \"value\": 0.9}]}, \"unit\": \"percentunit\"}, \"overrides\": []},\n      \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 16, \"y\": 6},\n      \"id\": 8,\n      \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}},\n      \"targets\": [{\"expr\": \"(1 - node_filesystem_avail_bytes{mountpoint=\\\"/\\\",fstype!~\\\"tmpfs|overlay\\\"} / node_filesystem_size_bytes{mountpoint=\\\"/\\\",fstype!~\\\"tmpfs|overlay\\\"}) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:9100\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}],\n      \"title\": \"Root disk pressure by node\",\n      \"type\": \"timeseries\"\n    }\n  ],\n  \"refresh\": \"30s\",\n  \"schemaVersion\": 42,\n  \"tags\": [\"homelab\", \"node\", \"drilldown\"],\n  \"time\": {\"from\": \"now-6h\", \"to\": \"now\"},\n  \"timepicker\": {\"refresh_intervals\": [\"30s\", \"1m\", \"5m\"], \"time_options\": [\"1h\", \"6h\", \"24h\", \"2d\", \"7d\"]},\n  \"timezone\": \"browser\",\n  \"title\": \"Homelab / Nodes\",\n  \"uid\": \"homelab-nodes\",\n  \"version\": 2\n}";
      "cilium.json" =
        "{\"annotations\":{\"list\":[]},\"panels\":[{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"fieldConfig\":{\"defaults\":{},\"overrides\":[]},\"gridPos\":{\"h\":8,\"w\":12,\"x\":0,\"y\":0},\"id\":1,\"targets\":[{\"expr\":\"sum(rate(hubble_flows_processed_total[5m])) by (type)\",\"legendFormat\":\"{{type}}\",\"refId\":\"A\"}],\"title\":\"Hubble flows\",\"type\":\"timeseries\"},{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"fieldConfig\":{\"defaults\":{},\"overrides\":[]},\"gridPos\":{\"h\":8,\"w\":12,\"x\":12,\"y\":0},\"id\":2,\"targets\":[{\"expr\":\"sum(rate(hubble_drop_total[5m])) by (reason)\",\"legendFormat\":\"{{reason}}\",\"refId\":\"A\"}],\"title\":\"Dropped flows\",\"type\":\"timeseries\"}],\"refresh\":\"30s\",\"schemaVersion\":42,\"tags\":[\"homelab\",\"cilium\",\"drilldown\"],\"time\":{\"from\":\"now-6h\",\"to\":\"now\"},\"title\":\"Homelab / Cilium and Hubble\",\"uid\":\"homelab-cilium\",\"version\":1}";
      "argocd.json" =
        "{\"annotations\":{\"list\":[]},\"description\":\"Git convergence and application health without inventory-only totals.\",\"panels\":[{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"description\":\"Applications whose current health is not Healthy.\",\"fieldConfig\":{\"defaults\":{\"noValue\":\"Unknown\",\"thresholds\":{\"mode\":\"absolute\",\"steps\":[{\"color\":\"green\",\"value\":null},{\"color\":\"orange\",\"value\":1},{\"color\":\"red\",\"value\":3}]},\"unit\":\"short\"},\"overrides\":[]},\"gridPos\":{\"h\":5,\"w\":6,\"x\":0,\"y\":0},\"id\":1,\"targets\":[{\"expr\":\"count(argocd_app_info{health_status!=\\\"Healthy\\\"}) or (0 * count(argocd_app_info))\",\"instant\":true,\"refId\":\"A\"}],\"title\":\"Unhealthy applications\",\"type\":\"stat\"},{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"description\":\"Applications whose live state differs from Git.\",\"fieldConfig\":{\"defaults\":{\"noValue\":\"Unknown\",\"thresholds\":{\"mode\":\"absolute\",\"steps\":[{\"color\":\"green\",\"value\":null},{\"color\":\"orange\",\"value\":1}]},\"unit\":\"short\"},\"overrides\":[]},\"gridPos\":{\"h\":5,\"w\":6,\"x\":6,\"y\":0},\"id\":2,\"targets\":[{\"expr\":\"count(argocd_app_info{sync_status!=\\\"Synced\\\"}) or (0 * count(argocd_app_info))\",\"instant\":true,\"refId\":\"A\"}],\"title\":\"Out-of-sync applications\",\"type\":\"stat\"},{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"description\":\"Application health distribution over the selected time range.\",\"fieldConfig\":{\"defaults\":{\"unit\":\"short\"},\"overrides\":[]},\"gridPos\":{\"h\":8,\"w\":12,\"x\":0,\"y\":5},\"id\":3,\"targets\":[{\"expr\":\"sum by (health_status) (argocd_app_info)\",\"legendFormat\":\"{{health_status}}\",\"refId\":\"A\"}],\"title\":\"Health distribution\",\"type\":\"timeseries\"},{\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"description\":\"Application synchronization distribution over the selected time range.\",\"fieldConfig\":{\"defaults\":{\"unit\":\"short\"},\"overrides\":[]},\"gridPos\":{\"h\":8,\"w\":12,\"x\":12,\"y\":5},\"id\":4,\"targets\":[{\"expr\":\"sum by (sync_status) (argocd_app_info)\",\"legendFormat\":\"{{sync_status}}\",\"refId\":\"A\"}],\"title\":\"Synchronization distribution\",\"type\":\"timeseries\"}],\"refresh\":\"30s\",\"schemaVersion\":42,\"tags\":[\"homelab\",\"argocd\",\"drilldown\"],\"time\":{\"from\":\"now-6h\",\"to\":\"now\"},\"title\":\"Homelab / Argo CD\",\"uid\":\"homelab-argocd\",\"version\":2}";
      "longhorn.json" =
        "{\n  \"annotations\": {\"list\": []},\n  \"description\": \"Storage durability, capacity pressure, I/O, and recovery-point freshness from Longhorn.\",\n  \"panels\": [\n    {\"collapsed\": false, \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0}, \"id\": 1, \"panels\": [], \"title\": \"Protection posture\", \"type\": \"row\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Longhorn volumes currently reporting healthy robustness.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"green\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 0, \"y\": 1}, \"id\": 2, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(longhorn_volume_robustness{state=\\\"healthy\\\"} == 1)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Healthy volumes\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Volumes in degraded or faulted state. Any non-zero value needs immediate investigation.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 6, \"y\": 1}, \"id\": 3, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(longhorn_volume_robustness{state=~\\\"degraded|faulted\\\"} == 1) or (0 * count(longhorn_volume_robustness{state=\\\"healthy\\\"}))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Volumes at risk\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Replicas in error or unknown runtime state.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 12, \"y\": 1}, \"id\": 4, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(longhorn_replica_state{state=~\\\"error|unknown\\\"} == 1) or (0 * count(longhorn_replica_state{state=\\\"running\\\"}))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Replica errors\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Age of the newest successful Longhorn volume backup. Red means the recovery point is older than 48 hours.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 24}, {\"color\": \"red\", \"value\": 48}]}, \"unit\": \"h\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 18, \"y\": 1}, \"id\": 5, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"(time() - max(longhorn_volume_last_backup_at)) / 3600\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Newest backup age\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Longhorn storage used on each node as a fraction of capacity.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 14, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"max\": 1, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.7}, {\"color\": \"red\", \"value\": 0.85}]}, \"unit\": \"percentunit\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 0, \"y\": 6}, \"id\": 6, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"longhorn_node_storage_usage_bytes / longhorn_node_storage_capacity_bytes\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}], \"title\": \"Node storage pressure\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Allocated bytes compared with requested volume capacity, grouped by persistent volume.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 14, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"max\": 1, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.75}, {\"color\": \"red\", \"value\": 0.9}]}, \"unit\": \"percentunit\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 8, \"y\": 6}, \"id\": 7, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"longhorn_volume_actual_size_bytes / longhorn_volume_capacity_bytes\", \"legendFormat\": \"{{pvc_namespace}} / {{pvc}}\", \"refId\": \"A\"}], \"title\": \"Volume allocation pressure\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Current read and write throughput by volume. A sudden sustained rise helps identify noisy storage consumers.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"unit\": \"Bps\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 16, \"y\": 6}, \"id\": 8, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"sum by (volume) (longhorn_volume_read_throughput)\", \"legendFormat\": \"read {{volume}}\", \"refId\": \"A\"}, {\"expr\": \"sum by (volume) (longhorn_volume_write_throughput)\", \"legendFormat\": \"write {{volume}}\", \"refId\": \"B\"}], \"title\": \"Volume throughput\", \"type\": \"timeseries\"}\n  ],\n  \"refresh\": \"30s\", \"schemaVersion\": 42, \"tags\": [\"homelab\", \"longhorn\", \"drilldown\"], \"time\": {\"from\": \"now-6h\", \"to\": \"now\"}, \"timepicker\": {\"refresh_intervals\": [\"30s\", \"1m\", \"5m\"], \"time_options\": [\"1h\", \"6h\", \"24h\", \"2d\", \"7d\"]}, \"timezone\": \"browser\", \"title\": \"Homelab / Longhorn\", \"uid\": \"homelab-longhorn\", \"version\": 3\n}";
      "postgres.json" =
        "{\n  \"annotations\": {\"list\": []},\n  \"description\": \"CloudNativePG availability, replication safety, archive freshness, and workload activity.\",\n  \"panels\": [\n    {\"collapsed\": false, \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0}, \"id\": 1, \"panels\": [], \"title\": \"Database posture\", \"type\": \"row\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"CloudNativePG instances whose collector is reachable and healthy.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"green\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 0, \"y\": 1}, \"id\": 2, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(cnpg_collector_up)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Healthy instances\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"CloudNativePG collectors reporting unhealthy. Any non-zero value indicates lost database visibility or availability.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 6, \"y\": 1}, \"id\": 3, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(cnpg_collector_up == 0) or (0 * count(cnpg_collector_up))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Unhealthy instances\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Maximum observed replication lag. Sustained lag reduces failover confidence.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 5}, {\"color\": \"red\", \"value\": 30}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 12, \"y\": 1}, \"id\": 4, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"max(cnpg_pg_replication_lag)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Maximum replica lag\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Number of database clusters currently exposing a primary instance.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"green\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 18, \"y\": 1}, \"id\": 5, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(cnpg_pg_replication_in_recovery == 0)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Primary clusters\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Replication lag by namespace and instance. Flat lines at zero indicate caught-up replicas.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 5}, {\"color\": \"red\", \"value\": 30}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 0, \"y\": 6}, \"id\": 6, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"cnpg_pg_replication_lag\", \"legendFormat\": \"{{namespace}} / {{pod}}\", \"refId\": \"A\"}], \"title\": \"Replication lag\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Seconds since the last successful WAL archive on each database namespace. This is the recovery-point freshness signal.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 900}, {\"color\": \"red\", \"value\": 3600}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 8, \"y\": 6}, \"id\": 7, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"max by (namespace) (cnpg_pg_stat_archiver_seconds_since_last_archival)\", \"legendFormat\": \"{{namespace}}\", \"refId\": \"A\"}], \"title\": \"WAL archive freshness\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Committed transactions per second by namespace, showing useful database activity rather than raw inventory.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"unit\": \"ops\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 16, \"y\": 6}, \"id\": 8, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"sum by (namespace) (rate(cnpg_pg_stat_database_xact_commit{datname!~\\\"template.*\\\"}[5m]))\", \"legendFormat\": \"{{namespace}}\", \"refId\": \"A\"}], \"title\": \"Committed transactions\", \"type\": \"timeseries\"}\n  ],\n  \"refresh\": \"30s\", \"schemaVersion\": 42, \"tags\": [\"homelab\", \"postgres\", \"drilldown\"], \"time\": {\"from\": \"now-6h\", \"to\": \"now\"}, \"timepicker\": {\"refresh_intervals\": [\"30s\", \"1m\", \"5m\"], \"time_options\": [\"1h\", \"6h\", \"24h\", \"2d\", \"7d\"]}, \"timezone\": \"browser\", \"title\": \"Homelab / PostgreSQL\", \"uid\": \"homelab-postgres\", \"version\": 3\n}";
      "homelab-etcd.json" =
        "{\n  \"annotations\": {\"list\": []},\n  \"description\": \"Embedded etcd quorum, stability, database size, and disk latency for the k3s control plane.\",\n  \"panels\": [\n    {\"collapsed\": false, \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0}, \"id\": 1, \"panels\": [], \"title\": \"Control-plane posture\", \"type\": \"row\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"etcd members that currently agree a leader exists. The healthy target is all three members.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"red\", \"value\": null}, {\"color\": \"orange\", \"value\": 2}, {\"color\": \"green\", \"value\": 3}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 0, \"y\": 1}, \"id\": 2, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(etcd_server_has_leader)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Members with leader\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Scraped etcd members without a leader. Any non-zero value threatens quorum safety.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 6, \"y\": 1}, \"id\": 3, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(etcd_server_has_leader == 0) or (0 * count(etcd_server_has_leader))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Members missing leader\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Largest observed etcd backend database. Rapid growth can increase snapshot and compaction time.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1073741824}, {\"color\": \"red\", \"value\": 2147483648}]}, \"unit\": \"bytes\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 12, \"y\": 1}, \"id\": 4, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"max(etcd_mvcc_db_total_size_in_bytes)\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Backend database size\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Leader elections seen across the cluster during the last hour. Stable clusters normally remain at zero.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 3}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 18, \"y\": 1}, \"id\": 5, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(increase(etcd_server_leader_changes_seen_total[1h]))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Leader changes in 1h\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"99th percentile WAL fsync duration by member. High latency delays durable consensus writes.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.01}, {\"color\": \"red\", \"value\": 0.05}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 0, \"y\": 6}, \"id\": 6, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"histogram_quantile(0.99, sum by (instance, le) (rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m]))) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:2381\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}], \"title\": \"WAL fsync p99\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"99th percentile backend commit duration by member. It reflects the disk path used for committed state.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.025}, {\"color\": \"red\", \"value\": 0.1}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 8, \"y\": 6}, \"id\": 7, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"histogram_quantile(0.99, sum by (instance, le) (rate(etcd_disk_backend_commit_duration_seconds_bucket[5m]))) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:2381\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}], \"title\": \"Backend commit p99\", \"type\": \"timeseries\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"99th percentile round-trip latency between etcd peers. Network delay directly affects consensus time.\", \"fieldConfig\": {\"defaults\": {\"custom\": {\"drawStyle\": \"line\", \"fillOpacity\": 12, \"lineWidth\": 2, \"showPoints\": \"never\", \"spanNulls\": true}, \"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 0.05}, {\"color\": \"red\", \"value\": 0.15}]}, \"unit\": \"s\"}, \"overrides\": []}, \"gridPos\": {\"h\": 8, \"w\": 8, \"x\": 16, \"y\": 6}, \"id\": 8, \"options\": {\"legend\": {\"calcs\": [\"lastNotNull\", \"max\"], \"displayMode\": \"table\", \"placement\": \"bottom\"}, \"tooltip\": {\"mode\": \"multi\", \"sort\": \"desc\"}}, \"targets\": [{\"expr\": \"histogram_quantile(0.99, sum by (instance, le) (rate(etcd_network_peer_round_trip_time_seconds_bucket[5m]))) * on(instance) group_left(node) label_replace(kube_node_info, \\\"instance\\\", \\\"$1:2381\\\", \\\"internal_ip\\\", \\\"(.*)\\\")\", \"legendFormat\": \"{{node}}\", \"refId\": \"A\"}], \"title\": \"Peer round trip p99\", \"type\": \"timeseries\"}\n  ],\n  \"refresh\": \"30s\", \"schemaVersion\": 42, \"tags\": [\"homelab\", \"etcd\", \"drilldown\"], \"time\": {\"from\": \"now-6h\", \"to\": \"now\"}, \"timepicker\": {\"refresh_intervals\": [\"30s\", \"1m\", \"5m\"], \"time_options\": [\"1h\", \"6h\", \"24h\", \"2d\", \"7d\"]}, \"timezone\": \"browser\", \"title\": \"Homelab / etcd\", \"uid\": \"homelab-etcd\", \"version\": 2\n}";
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "default-deny";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "monitoring";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-observability";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "monitoring";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "monitoring";
                };
              };
            }
          ];
        }
        {
          from = [
            {
              namespaceSelector = { };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 4317;
            }
            {
              protocol = "TCP";
              port = 4318;
            }
          ];
        }
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "argo-rollouts";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 9090;
            }
          ];
        }
      ];
      egress = [
        {
          to = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "kube-system";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "UDP";
              port = 53;
            }
            {
              protocol = "TCP";
              port = 53;
            }
          ];
        }
        {
          to = [
            {
              namespaceSelector = { };
            }
          ];
        }
        {
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
            {
              protocol = "TCP";
              port = 6443;
            }
            {
              protocol = "TCP";
              port = 9100;
            }
            {
              protocol = "TCP";
              port = 10250;
            }
            {
              protocol = "TCP";
              port = 2381;
            }
            {
              protocol = "TCP";
              port = 9962;
            }
            {
              protocol = "TCP";
              port = 9963;
            }
            {
              protocol = "TCP";
              port = 9964;
            }
            {
              protocol = "TCP";
              port = 9965;
            }
            {
              protocol = "TCP";
              port = 9966;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "openbao-auth";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authentication";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    automountServiceAccountToken = false;
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "Role";
    metadata = {
      name = "mint-openbao-auth-token";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "serviceaccounts/token"
        ];
        resourceNames = [
          "openbao-auth"
        ];
        verbs = [
          "create"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";
    metadata = {
      name = "allow-external-secrets-to-mint-openbao-token";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "Role";
      name = "mint-openbao-auth-token";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "external-secrets";
        namespace = "external-secrets";
      }
    ];
  }
  {
    apiVersion = "monitoring.coreos.com/v1alpha1";
    kind = "AlertmanagerConfig";
    metadata = {
      name = "platform";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "alertmanager";
        "app.kubernetes.io/component" = "routing";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      route = {
        receiver = "platform-webhook";
        groupBy = [
          "alertname"
          "namespace"
        ];
        groupWait = "30s";
        groupInterval = "5m";
        repeatInterval = "4h";
      };
      receivers = [
        {
          name = "platform-webhook";
          webhookConfigs = [
            {
              sendResolved = true;
              urlSecret = {
                name = "alertmanager-notification";
                key = "webhook-url";
              };
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "SecretStore";
    metadata = {
      name = "openbao";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "openbao";
        "app.kubernetes.io/component" = "secret-store";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      provider = {
        vault = {
          server = "https://openbao-active.openbao.svc:8200";
          path = "secret";
          version = "v2";
          caProvider = {
            type = "Secret";
            name = "openbao-ca";
            key = "ca.crt";
          };
          auth = {
            kubernetes = {
              mountPath = "kubernetes";
              role = "runtime-monitoring";
              serviceAccountRef = {
                name = "openbao-auth";
                audiences = [
                  "openbao"
                ];
              };
            };
          };
        };
      };
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ExternalSecret";
    metadata = {
      name = "alertmanager-notification";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "alertmanager-notification";
        "app.kubernetes.io/component" = "notification";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      refreshInterval = "1h";
      secretStoreRef = {
        kind = "SecretStore";
        name = "openbao";
      };
      target = {
        name = "alertmanager-notification";
        creationPolicy = "Owner";
        deletionPolicy = "Retain";
      };
      data = [
        {
          secretKey = "webhook-url";
          remoteRef = {
            key = "monitoring/alertmanager-notification";
            property = "webhook-url";
          };
        }
      ];
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ExternalSecret";
    metadata = {
      name = "grafana-admin";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "grafana-admin";
        "app.kubernetes.io/component" = "authentication";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      refreshInterval = "1h";
      secretStoreRef = {
        kind = "SecretStore";
        name = "openbao";
      };
      target = {
        name = "grafana-admin";
        creationPolicy = "Owner";
        deletionPolicy = "Retain";
      };
      data = [
        {
          secretKey = "admin-user";
          remoteRef = {
            key = "monitoring/grafana-admin";
            property = "admin-user";
          };
        }
        {
          secretKey = "admin-password";
          remoteRef = {
            key = "monitoring/grafana-admin";
            property = "admin-password";
          };
        }
        {
          secretKey = "GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET";
          remoteRef = {
            key = "monitoring/grafana-oidc";
            property = "client-secret";
          };
        }
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "openbao-auth";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authentication";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    automountServiceAccountToken = false;
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "Role";
    metadata = {
      name = "mint-openbao-auth-token";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "serviceaccounts/token"
        ];
        resourceNames = [
          "openbao-auth"
        ];
        verbs = [
          "create"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";
    metadata = {
      name = "allow-external-secrets-to-mint-openbao-token";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "Role";
      name = "mint-openbao-auth-token";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "external-secrets";
        namespace = "external-secrets";
      }
    ];
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ExternalSecret";
    metadata = {
      name = "argocd-oidc";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "argocd-oidc";
        "app.kubernetes.io/component" = "authentication";
        "app.kubernetes.io/part-of" = "argocd";
      };
    };
    spec = {
      refreshInterval = "1h";
      secretStoreRef = {
        kind = "SecretStore";
        name = "openbao";
      };
      target = {
        name = "argocd-oidc";
        creationPolicy = "Owner";
        deletionPolicy = "Retain";
        template = {
          metadata = {
            labels = {
              "app.kubernetes.io/part-of" = "argocd";
            };
          };
        };
      };
      data = [
        {
          secretKey = "client-secret";
          remoteRef = {
            key = "argocd/oidc";
            property = "client-secret";
          };
        }
      ];
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "SecretStore";
    metadata = {
      name = "openbao";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "openbao";
        "app.kubernetes.io/component" = "secret-store";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      provider = {
        vault = {
          server = "https://openbao-active.openbao.svc:8200";
          path = "secret";
          version = "v2";
          caProvider = {
            type = "Secret";
            name = "openbao-ca";
            key = "ca.crt";
          };
          auth = {
            kubernetes = {
              mountPath = "kubernetes";
              role = "runtime-argocd";
              serviceAccountRef = {
                name = "openbao-auth";
                audiences = [
                  "openbao"
                ];
              };
            };
          };
        };
      };
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ExternalSecret";
    metadata = {
      name = "argocd-notifications";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "argocd-notifications";
        "app.kubernetes.io/component" = "notification";
        "app.kubernetes.io/part-of" = "observability";
      };
    };
    spec = {
      refreshInterval = "1h";
      secretStoreRef = {
        kind = "SecretStore";
        name = "openbao";
      };
      target = {
        name = "argocd-notifications-secret";
        creationPolicy = "Owner";
        deletionPolicy = "Retain";
      };
      data = [
        {
          secretKey = "webhook-url";
          remoteRef = {
            key = "argocd/notifications";
            property = "webhook-url";
          };
        }
      ];
    };
  }
]
