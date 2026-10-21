# One-time conversion from:
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/allow-database-kubernetes-api.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/archive-database-to-object-storage.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/deploy-storage-verification-database.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/restrict-database-network.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/restrict-database-network.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/restrict-database-operators.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/restrict-database-operators.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudnative-pg/resources/schedule-database-backups.yaml
[
  {
    apiVersion = "cilium.io/v2";
    kind = "CiliumNetworkPolicy";
    metadata = {
      name = "allow-database-kubernetes-api";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-verification";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      endpointSelector = {
        matchLabels = {
          "cnpg.io/cluster" = "storage-verification";
        };
      };
      egress = [
        {
          toEntities = [
            "kube-apiserver"
          ];
        }
      ];
    };
  }
  {
    apiVersion = "barmancloud.cnpg.io/v1";
    kind = "ObjectStore";
    metadata = {
      name = "homelab-s3";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "homelab-s3";
        "app.kubernetes.io/component" = "backup";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      retentionPolicy = "30d";
      configuration = {
        destinationPath = "s3://\${CONFIG_S3_BUCKET}/cnpg";
        endpointURL = "\${CONFIG_S3_ENDPOINT}";
        s3Credentials = {
          accessKeyId = {
            name = "cnpg-s3-credentials";
            key = "ACCESS_KEY_ID";
          };
          secretAccessKey = {
            name = "cnpg-s3-credentials";
            key = "ACCESS_SECRET_KEY";
          };
        };
        wal = {
          compression = "gzip";
          maxParallel = 2;
        };
        data = {
          compression = "gzip";
          jobs = 2;
        };
      };
      instanceSidecarConfiguration = {
        retentionPolicyIntervalSeconds = 1800;
        resources = {
          requests = {
            cpu = "30m";
            memory = "64Mi";
          };
          limits = {
            cpu = "500m";
            memory = "256Mi";
          };
        };
      };
    };
  }
  {
    apiVersion = "postgresql.cnpg.io/v1";
    kind = "Cluster";
    metadata = {
      name = "storage-verification";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-verification-postgres";
        "app.kubernetes.io/component" = "database";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      instances = 3;
      imageName = "\${CNPG_POSTGRES_IMAGE}";
      primaryUpdateStrategy = "unsupervised";
      enableSuperuserAccess = false;
      inheritedMetadata = {
        labels = {
          "app.kubernetes.io/name" = "storage-verification-postgres";
          "app.kubernetes.io/component" = "database";
          "app.kubernetes.io/part-of" = "storage";
        };
      };
      resources = {
        requests = {
          cpu = "100m";
          memory = "256Mi";
        };
        limits = {
          cpu = "1";
          memory = "1Gi";
        };
      };
      storage = {
        size = "5Gi";
        storageClass = "longhorn-database";
      };
      walStorage = {
        size = "5Gi";
        storageClass = "longhorn-database";
      };
      affinity = {
        enablePodAntiAffinity = true;
        topologyKey = "kubernetes.io/hostname";
        podAntiAffinityType = "required";
      };
      plugins = [
        {
          name = "barman-cloud.cloudnative-pg.io";
          isWALArchiver = true;
          parameters = {
            barmanObjectName = "homelab-s3";
          };
        }
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "deny-ingress-by-default";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-verification-network";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
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
      name = "allow-database-operation";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-verification-network";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
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
              podSelector = { };
            }
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "cnpg-system";
                };
              };
            }
          ];
        }
      ];
      egress = [
        {
          to = [
            {
              podSelector = { };
            }
          ];
        }
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
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "restrict-cloudnative-pg-operator";
      namespace = "cnpg-system";
      labels = {
        "app.kubernetes.io/name" = "cloudnative-pg";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "cloudnative-pg";
          "app.kubernetes.io/instance" = "cloudnative-pg";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          ports = [
            {
              protocol = "TCP";
              port = 8080;
            }
            {
              protocol = "TCP";
              port = 9443;
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
              podSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "plugin-barman-cloud";
                  "app.kubernetes.io/instance" = "barman-cloud";
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
        {
          ports = [
            {
              protocol = "TCP";
              port = 8000;
            }
            {
              protocol = "TCP";
              port = 443;
            }
            {
              protocol = "TCP";
              port = 6443;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "restrict-barman-cloud-controller";
      namespace = "cnpg-system";
      labels = {
        "app.kubernetes.io/name" = "plugin-barman-cloud";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "plugin-barman-cloud";
          "app.kubernetes.io/instance" = "barman-cloud";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          ports = [
            {
              protocol = "TCP";
              port = 8081;
            }
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
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
            {
              protocol = "TCP";
              port = 6443;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "postgresql.cnpg.io/v1";
    kind = "ScheduledBackup";
    metadata = {
      name = "daily-storage-verification";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "daily-storage-verification";
        "app.kubernetes.io/component" = "backup";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      schedule = "0 0 3 * * *";
      backupOwnerReference = "self";
      immediate = false;
      cluster = {
        name = "storage-verification";
      };
      method = "plugin";
      pluginConfiguration = {
        name = "barman-cloud.cloudnative-pg.io";
      };
    };
  }
]
