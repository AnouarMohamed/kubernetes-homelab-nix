# Generated once from /home/anouar/kubernetes-homelab/observability/alloy/configure-alloy.yaml
[
  {
    image = {
      tag = "v1.20.1";
      digest = "sha256:2aa2099af76c0098d4af7a4d6e48f86cb66dc1a000222ad927a1c67c6542d13f";
    };
    global = {
      podSecurityContext = {
        runAsNonRoot = true;
        runAsUser = 473;
        runAsGroup = 473;
        fsGroup = 473;
        seccompProfile = {
          type = "RuntimeDefault";
        };
      };
    };
    alloy = {
      storagePath = "/tmp/alloy";
      mounts = {
        extra = [
          {
            name = "storage";
            mountPath = "/tmp/alloy";
          }
        ];
      };
      clustering = {
        enabled = true;
      };
      configMap = {
        content = "logging {\n  level  = \"info\"\n  format = \"json\"\n}\n\ndiscovery.kubernetes \"pods\" {\n  role = \"pod\"\n}\n\ndiscovery.relabel \"pod_logs\" {\n  targets = discovery.kubernetes.pods.targets\n\n  rule {\n    source_labels = [\"__meta_kubernetes_namespace\"]\n    target_label  = \"namespace\"\n  }\n\n  rule {\n    source_labels = [\"__meta_kubernetes_pod_name\"]\n    target_label  = \"pod\"\n  }\n\n  rule {\n    source_labels = [\"__meta_kubernetes_pod_container_name\"]\n    target_label  = \"container\"\n  }\n}\n\nloki.source.kubernetes \"pods\" {\n  targets    = discovery.relabel.pod_logs.output\n  forward_to = [loki.process.pods.receiver]\n}\n\nloki.process \"pods\" {\n  stage.cri {}\n  forward_to = [loki.write.local.receiver]\n}\n\nloki.write \"local\" {\n  endpoint {\n    url = \"http://loki.monitoring.svc:3100/loki/api/v1/push\"\n  }\n}";
      };
      resources = {
        requests = {
          cpu = "100m";
          memory = "128Mi";
        };
        limits = {
          cpu = "500m";
          memory = "512Mi";
        };
      };
      livenessProbe = {
        httpGet = {
          path = "/-/ready";
          port = 12345;
        };
        initialDelaySeconds = 10;
        periodSeconds = 20;
      };
      securityContext = {
        allowPrivilegeEscalation = false;
        capabilities = {
          drop = [
            "ALL"
          ];
        };
        readOnlyRootFilesystem = true;
        runAsNonRoot = true;
        runAsUser = 473;
        runAsGroup = 473;
      };
    };
    controller = {
      type = "deployment";
      replicas = 2;
      volumes = {
        extra = [
          {
            name = "storage";
            emptyDir = { };
          }
        ];
      };
      podDisruptionBudget = {
        enabled = true;
        minAvailable = 1;
      };
      topologySpreadConstraints = [
        {
          maxSkew = 1;
          topologyKey = "kubernetes.io/hostname";
          whenUnsatisfiable = "DoNotSchedule";
          labelSelector = {
            matchLabels = {
              "app.kubernetes.io/name" = "alloy";
            };
          };
        }
      ];
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "alloy";
                  "app.kubernetes.io/instance" = "alloy";
                };
              };
              topologyKey = "kubernetes.io/hostname";
            }
          ];
        };
      };
    };
    configReloader = {
      enabled = false;
    };
    serviceMonitor = {
      enabled = true;
      additionalLabels = {
        release = "monitoring";
      };
    };
  }
]
