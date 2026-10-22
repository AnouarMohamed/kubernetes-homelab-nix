# Generated once from /home/anouar/kubernetes-homelab/platform/cert-manager/configure-cert-manager.yaml
[
  {
    image.digest = "sha256:416a2d76870d996460e62bd7f521bf14fa017be9e3e904aab92163a331fcb61a";
    crds = {
      enabled = true;
      keep = true;
    };
    replicaCount = 2;
    podDisruptionBudget = {
      enabled = true;
      maxUnavailable = 1;
    };
    prometheus = {
      enabled = true;
      servicemonitor = {
        enabled = false;
      };
    };
    networkPolicy = {
      enabled = true;
    };
    resources = {
      requests = {
        cpu = "20m";
        memory = "64Mi";
      };
      limits = {
        cpu = "500m";
        memory = "256Mi";
      };
    };
    webhook = {
      image.digest = "sha256:d8b3961b51c8c7320633f8208dc46bf88aa13804d0f7cbe48a096b2c523cee42";
      replicaCount = 2;
      podDisruptionBudget = {
        enabled = true;
        maxUnavailable = 1;
      };
      networkPolicy = {
        enabled = true;
      };
      resources = {
        requests = {
          cpu = "20m";
          memory = "64Mi";
        };
        limits = {
          cpu = "500m";
          memory = "256Mi";
        };
      };
    };
    cainjector = {
      image.digest = "sha256:ccf6b919ec0500745a47a910118f834f9636d0aac1ff221245cd2557ed8c7c98";
      enabled = true;
      replicaCount = 2;
      podDisruptionBudget = {
        enabled = true;
        maxUnavailable = 1;
      };
      networkPolicy = {
        enabled = true;
      };
      resources = {
        requests = {
          cpu = "20m";
          memory = "64Mi";
        };
        limits = {
          cpu = "500m";
          memory = "256Mi";
        };
      };
    };
    startupapicheck = {
      enabled = true;
      resources = {
        requests = {
          cpu = "10m";
          memory = "32Mi";
        };
        limits = {
          cpu = "100m";
          memory = "64Mi";
        };
      };
    };
  }
]
