{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.homelab;
  nodeType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      address = mkOption { type = types.str; };
      interface = mkOption { type = types.str; };
      installDisk = mkOption { type = types.str; };
      clusterInit = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
in
{
  options.homelab = {
    domain = mkOption { type = types.str; };
    acmeEmail = mkOption { type = types.str; };
    timezone = mkOption {
      type = types.str;
      default = "UTC";
    };
    adminUser = mkOption {
      type = types.strMatching "[a-z_][a-z0-9_-]*";
      default = "operator";
    };
    repository = mkOption { type = types.str; };
    projectPath = mkOption { type = types.str; };
    registryPath = mkOption { type = types.str; };
    ciIdentity = mkOption { type = types.str; };
    kubernetes = {
      version = mkOption { type = types.strMatching "[0-9]+[.][0-9]+[.][0-9]+"; };
      minor = mkOption { type = types.strMatching "[0-9]+[.][0-9]+"; };
    };
    images = mkOption { type = types.attrsOf types.str; };
    hardwareProfile = {
      cpuModel = mkOption { type = types.str; };
      cores = mkOption { type = types.ints.positive; };
      threads = mkOption { type = types.ints.positive; };
      memoryGiB = mkOption { type = types.ints.positive; };
      diskModel = mkOption { type = types.str; };
      diskSizeGB = mkOption { type = types.ints.positive; };
      installDisk = mkOption { type = types.str; };
      interface = mkOption { type = types.str; };
    };
    nodes = mkOption { type = types.listOf nodeType; };
    network = {
      adminCidr = mkOption { type = types.str; };
      privateRouteCidr = mkOption { type = types.str; };
      podCidr = mkOption { type = types.str; };
      serviceCidr = mkOption { type = types.str; };
      controlPlaneVip = mkOption { type = types.str; };
      loadBalancerPool = {
        start = mkOption { type = types.str; };
        stop = mkOption { type = types.str; };
      };
    };
    storage = {
      defaultClass = mkOption {
        type = types.str;
        default = "longhorn";
      };
      databaseClass = mkOption {
        type = types.str;
        default = "longhorn-database";
      };
      longhornDiskPath = mkOption {
        type = types.str;
        default = "/var/lib/longhorn";
      };
      s3Endpoint = mkOption { type = types.str; };
      s3Bucket = mkOption { type = types.str; };
    };
    replicas = {
      controlPlane = mkOption {
        type = types.ints.positive;
        default = 3;
      };
      platform = mkOption {
        type = types.ints.positive;
        default = 2;
      };
      databases = mkOption {
        type = types.ints.positive;
        default = 3;
      };
    };
    components = mkOption {
      type = types.attrsOf types.bool;
      default = { };
    };
    sshAuthorizedKey = mkOption { type = types.str; };
    ageRecipient = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
    hostTunnel = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      tunnelId = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config.assertions = [
    {
      assertion = builtins.length cfg.nodes == 3;
      message = "The HA reference topology requires exactly three nodes.";
    }
    {
      assertion = builtins.length (builtins.filter (node: node.clusterInit) cfg.nodes) == 1;
      message = "Exactly one node must initialize the embedded-etcd cluster.";
    }
    {
      assertion = builtins.all (node: lib.hasPrefix "/dev/disk/by-" node.installDisk) cfg.nodes;
      message = "Every installation disk must use a stable /dev/disk/by-* path.";
    }
    {
      assertion = lib.hasPrefix cfg.kubernetes.minor cfg.kubernetes.version;
      message = "homelab.kubernetes.version must belong to homelab.kubernetes.minor.";
    }
    {
      assertion = !cfg.hostTunnel.enable || cfg.hostTunnel.tunnelId != null;
      message = "homelab.hostTunnel.tunnelId is required when the host tunnel is enabled.";
    }
    {
      assertion = cfg.sopsFile == null || cfg.ageRecipient != null;
      message = "homelab.ageRecipient is required when homelab.sopsFile is configured.";
    }
  ];
}
