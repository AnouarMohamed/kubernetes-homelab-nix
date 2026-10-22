# Generated once from /home/anouar/kubernetes-homelab/platform/cloudnative-pg/configure-cloudnative-pg.yaml
[
  {
    image.tag = "1.30.1@sha256:923c267ec29636db3bee20f993d0ec4973fa22998e1adad37da79e4d32b5bc07";
    replicaCount = 2;
    resources = {
      requests = {
        cpu = "50m";
        memory = "128Mi";
      };
      limits = {
        cpu = "500m";
        memory = "384Mi";
      };
    };
    topologySpreadConstraints = [
      {
        maxSkew = 1;
        topologyKey = "kubernetes.io/hostname";
        whenUnsatisfiable = "DoNotSchedule";
        labelSelector = {
          matchLabels = {
            "app.kubernetes.io/name" = "cloudnative-pg";
          };
        };
      }
    ];
    affinity = {
      podAntiAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = [
          {
            topologyKey = "kubernetes.io/hostname";
            labelSelector = {
              matchLabels = {
                "app.kubernetes.io/name" = "cloudnative-pg";
              };
            };
          }
        ];
      };
    };
    monitoring = {
      podMonitorEnabled = false;
    };
  }
]
