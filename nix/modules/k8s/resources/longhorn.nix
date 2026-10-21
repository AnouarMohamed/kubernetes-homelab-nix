# One-time conversion from:
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/allocate-volume-snapshots.yaml
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/allow-monitoring-scrapes.yaml
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/define-database-storage-class.yaml
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/mark-local-path-non-default.yaml
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/schedule-recurring-storage-protection.yaml
# - /home/anouar/kubernetes-homelab/platform/longhorn/resources/schedule-recurring-storage-protection.yaml
[
  {
    apiVersion = "snapshot.storage.k8s.io/v1";
    kind = "VolumeSnapshotClass";
    metadata = {
      name = "longhorn-snapshot";
      labels = {
        "app.kubernetes.io/name" = "longhorn-snapshot";
        "app.kubernetes.io/component" = "backup";
        "app.kubernetes.io/part-of" = "storage";
        "velero.io/csi-volumesnapshot-class" = "true";
      };
    };
    driver = "driver.longhorn.io";
    deletionPolicy = "Delete";
    parameters = {
      type = "snap";
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-monitoring-scrapes";
      namespace = "longhorn-system";
      labels = {
        "app.kubernetes.io/name" = "longhorn";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          app = "longhorn-manager";
        };
      };
      policyTypes = [
        "Ingress"
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
          ports = [
            {
              protocol = "TCP";
              port = 9500;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "storage.k8s.io/v1";
    kind = "StorageClass";
    metadata = {
      name = "longhorn-database";
      labels = {
        "app.kubernetes.io/name" = "longhorn-database";
        "app.kubernetes.io/component" = "database-storage";
        "app.kubernetes.io/part-of" = "longhorn";
      };
    };
    provisioner = "driver.longhorn.io";
    parameters = {
      numberOfReplicas = "2";
      dataLocality = "best-effort";
    };
    allowVolumeExpansion = true;
    reclaimPolicy = "Retain";
  }
  {
    apiVersion = "storage.k8s.io/v1";
    kind = "StorageClass";
    metadata = {
      name = "local-path";
      labels = {
        "app.kubernetes.io/name" = "local-path";
        "app.kubernetes.io/component" = "legacy-storage";
        "app.kubernetes.io/part-of" = "storage";
      };
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "false";
      };
    };
    provisioner = "rancher.io/local-path";
    reclaimPolicy = "Delete";
    volumeBindingMode = "WaitForFirstConsumer";
  }
  {
    apiVersion = "longhorn.io/v1beta2";
    kind = "RecurringJob";
    metadata = {
      name = "hourly-snapshot";
      namespace = "longhorn-system";
      labels = {
        "app.kubernetes.io/name" = "hourly-snapshot";
        "app.kubernetes.io/component" = "backup";
        "app.kubernetes.io/part-of" = "storage";
        "recurring-job-group.longhorn.io/standard-storage-protection" = "enabled";
      };
    };
    spec = {
      cron = "15 * * * *";
      task = "snapshot";
      retain = 24;
      concurrency = 1;
    };
  }
  {
    apiVersion = "longhorn.io/v1beta2";
    kind = "RecurringJob";
    metadata = {
      name = "daily-backup";
      namespace = "longhorn-system";
      labels = {
        "app.kubernetes.io/name" = "daily-backup";
        "app.kubernetes.io/component" = "backup";
        "app.kubernetes.io/part-of" = "storage";
        "recurring-job-group.longhorn.io/standard-storage-protection" = "enabled";
      };
    };
    spec = {
      cron = "30 2 * * *";
      task = "backup";
      retain = 14;
      concurrency = 1;
      parameters = {
        full-backup-interval = "7";
      };
    };
  }
]
