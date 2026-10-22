# Generated once from /home/anouar/kubernetes-homelab/platform/cloudnative-pg/configure-barman-cloud.yaml
[
  {
    image.tag = "v0.15.1@sha256:c75acad19a36e8176cfe2885761ff1b836c6ef977d7257e298c99a28b5c302ef";
    sidecarImage.tag = "v0.15.1@sha256:2287a793a804db751edd0d07d44cd549e357677e98a800eb12e2cf7c0d53f9b0";
    replicaCount = 2;
    resources = {
      requests = {
        cpu = "30m";
        memory = "64Mi";
      };
      limits = {
        cpu = "300m";
        memory = "256Mi";
      };
    };
    topologySpreadConstraints = [
      {
        maxSkew = 1;
        topologyKey = "kubernetes.io/hostname";
        whenUnsatisfiable = "DoNotSchedule";
        labelSelector = {
          matchLabels = {
            "app.kubernetes.io/name" = "plugin-barman-cloud";
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
                "app.kubernetes.io/name" = "plugin-barman-cloud";
              };
            };
          }
        ];
      };
    };
  }
]
