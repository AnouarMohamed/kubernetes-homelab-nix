# Generated once from /home/anouar/kubernetes-homelab/platform/chaos-mesh/configure-chaos-mesh.yaml
[
  {
    clusterScoped = true;
    timezone = "\${CONFIG_TIMEZONE}";
    enableProfiling = false;
    images = {
      registry = "ghcr.io";
      tag = "v2.8.4";
    };
    controllerManager = {
      image.tag = "v2.8.4@sha256:9e48285bb44c63be80f2fe4468c54b0f2d7cdc447ba5f5bc9ded4ab6a973cd37";
      replicaCount = 3;
      enableFilterNamespace = true;
      allowHostNetworkTesting = false;
      chaosdSecurityMode = false;
      imagePullPolicy = "IfNotPresent";
      podChaos = {
        podFailure = {
          pauseImage = "registry.k8s.io/pause:3.10.1@sha256:278fb9dbcca9518083ad1e11276933a2e96f23de604a3a08cc3c80002767d24c";
        };
      };
      resources = {
        requests = {
          cpu = "50m";
          memory = "256Mi";
        };
        limits = {
          cpu = "500m";
          memory = "768Mi";
        };
      };
      securityContext = {
        runAsNonRoot = true;
        runAsUser = 65532;
        runAsGroup = 65532;
        seccompProfile = {
          type = "RuntimeDefault";
        };
      };
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              topologyKey = "kubernetes.io/hostname";
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/component" = "controller-manager";
                };
              };
            }
          ];
        };
      };
    };
    chaosDaemon = {
      image.tag = "v2.8.4@sha256:0d28dbd95b033279f65605ea88c354d25fe902409197274016dd2efc28ef25cd";
      runtime = "containerd";
      socketPath = "/run/k3s/containerd/containerd.sock";
      privileged = true;
      imagePullPolicy = "IfNotPresent";
      mtls = {
        enabled = false;
      };
      resources = {
        requests = {
          cpu = "100m";
          memory = "128Mi";
        };
        limits = {
          cpu = "1";
          memory = "512Mi";
        };
      };
    };
    dashboard = {
      create = false;
    };
    dnsServer = {
      create = false;
    };
    prometheus = {
      create = false;
    };
    bpfki = {
      create = false;
    };
    webhook = {
      certManager = {
        enabled = true;
      };
    };
  }
]
