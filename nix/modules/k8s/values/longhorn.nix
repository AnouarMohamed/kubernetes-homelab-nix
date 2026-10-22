# Generated once from /home/anouar/kubernetes-homelab/platform/longhorn/configure-longhorn.yaml
[
  {
    global = {
      timezone = "\${CONFIG_TIMEZONE}";
    };
    # Longhorn passes several of these references to system-managed workloads
    # at runtime, so every tag is paired with an immutable OCI index digest.
    image = {
      longhorn = {
        engine.tag = "v1.12.1@sha256:9b1b720b56df6612c9589cbc156acbca6419fa61de818d05db7226b0722f2868";
        manager.tag = "v1.12.1@sha256:83b79f57043fe1405e68bc0d4c7987accbc6bb512def3e0db12b31966c070801";
        ui.tag = "v1.12.1@sha256:03a3ce6673df6e948c261fe978a695adaa8fb190d68bfe5c358af8ee3d3fbef5";
        instanceManager.tag = "v1.12.1@sha256:b255f3279dd9d830ea153e9369928646dee519fd853036388926dddb5c66094b";
        shareManager.tag = "v1.12.1@sha256:efaf47aeb4e8615e312f0880df860bf2e5b9fa53006fe075f057c6dd4089f47d";
        backingImageManager.tag = "v1.12.1@sha256:dfb9452e4190fb80e39c7976a0036ac0ca314c05328b67952f8c165cbb4dabf3";
        supportBundleKit.tag = "v0.0.92@sha256:02baa824d9a4174747ab9db2635ae000b1198d2d5ed3a4c69caf28724224e783";
      };
      csi = {
        attacher.tag = "v4.12.0@sha256:a814aa4784197116983ea13e376fc691e000a390de9d0b9fca2bc4a2fb7c4a1f";
        provisioner.tag = "v5.3.0@sha256:1bbb7b11d8087130e722e3249f364d0ab49ee3545e847c2f299e87b7e1ce5c4f";
        nodeDriverRegistrar.tag = "v2.17.0@sha256:29f7cfd519008fe8f8dff5e79db43f70d65c43a89c08f1bafbb199ca90df79f0";
        resizer.tag = "v2.2.1@sha256:63d0aef25114d4a682b25afa6d9623a3cfcc19aca910269124408476bbe2c6fd";
        snapshotter.tag = "v8.6.0@sha256:2bca9ac55170efa61dc50e5cc8d9550373db2e3e5161d82d3fdaac5c25150360";
        livenessProbe.tag = "v2.19.0@sha256:d0cb76b565ba9d36da0dc2b38e2b6a49a0ae4fe067b03086110682f32c600318";
      };
    };
    networkPolicies = {
      enabled = true;
      restrictInternalTraffic = true;
      type = "k3s";
    };
    persistence = {
      createStorageClass = true;
      defaultClass = true;
      defaultClassReplicaCount = 3;
      defaultDataLocality = "disabled";
      reclaimPolicy = "Retain";
      volumeBindingMode = "WaitForFirstConsumer";
      recurringJobSelector = {
        enable = true;
        jobList = "[{\"name\":\"standard-storage-protection\",\"isGroup\":true}]";
      };
    };
    preUpgradeChecker = {
      jobEnabled = false;
      upgradeVersionCheck = false;
    };
    csi = {
      kubeletRootDir = "/var/lib/kubelet";
      attacherReplicaCount = 3;
      provisionerReplicaCount = 3;
      resizerReplicaCount = 3;
      snapshotterReplicaCount = 3;
    };
    defaultSettings = {
      allowRecurringJobWhileVolumeDetached = true;
      createDefaultDiskLabeledNodes = false;
      defaultDataPath = "\${CONFIG_LONGHORN_DISK_PATH}";
      defaultReplicaCount = "{\"v1\":\"3\",\"v2\":\"3\"}";
      replicaAutoBalance = "best-effort";
      storageMinimalAvailablePercentage = 25;
      storageOverProvisioningPercentage = 125;
      upgradeChecker = false;
      allowCollectingLonghornUsageMetrics = false;
      backupCompressionMethod = "lz4";
      backupConcurrentLimit = 2;
      restoreConcurrentLimit = 2;
    };
    defaultBackupStore = {
      backupTarget = "s3://\${CONFIG_S3_BUCKET}@us-east-1/longhorn";
      backupTargetCredentialSecret = "longhorn-s3-credentials";
      pollInterval = 300;
    };
    longhornManager = {
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
    longhornUI = {
      replicas = 2;
      resources = {
        requests = {
          cpu = "20m";
          memory = "64Mi";
        };
        limits = {
          cpu = "300m";
          memory = "256Mi";
        };
      };
    };
    metrics = {
      serviceMonitor = {
        enabled = false;
      };
    };
  }
]
