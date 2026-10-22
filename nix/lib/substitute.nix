{ lib, homelab }:
let
  replacements = {
    CONFIG_DOMAIN = homelab.domain;
    CONFIG_ACME_EMAIL = homelab.acmeEmail;
    CONFIG_GITHUB_REPOSITORY_URL = homelab.repository;
    CONFIG_GITHUB_PROJECT_PATH = homelab.projectPath;
    CONFIG_GHCR_REGISTRY_PATH = homelab.registryPath;
    CONFIG_GITHUB_CI_IDENTITY = homelab.ciIdentity;
    CONFIG_CONTROL_PLANE_VIP = homelab.network.controlPlaneVip;
    CONFIG_LOAD_BALANCER_POOL_START = homelab.network.loadBalancerPool.start;
    CONFIG_LOAD_BALANCER_POOL_STOP = homelab.network.loadBalancerPool.stop;
    CONFIG_LOAD_BALANCER_START = homelab.network.loadBalancerPool.start;
    CONFIG_LOAD_BALANCER_STOP = homelab.network.loadBalancerPool.stop;
    CONFIG_NODE_INTERFACE_PATTERN = "^(${
      lib.concatStringsSep "|" (map (node: node.interface) homelab.nodes)
    })$";
    CONFIG_NODE_1_ADDRESS = (builtins.elemAt homelab.nodes 0).address;
    CONFIG_NODE_2_ADDRESS = (builtins.elemAt homelab.nodes 1).address;
    CONFIG_NODE_3_ADDRESS = (builtins.elemAt homelab.nodes 2).address;
    CONFIG_PRIVATE_ROUTE_CIDR = homelab.network.privateRouteCidr;
    CONFIG_POD_CIDR = homelab.network.podCidr;
    CONFIG_SERVICE_CIDR = homelab.network.serviceCidr;
    CONFIG_LONGHORN_DISK_PATH = homelab.storage.longhornDiskPath;
    CONFIG_TIMEZONE = homelab.timezone;
    CONFIG_S3_ENDPOINT = homelab.storage.s3Endpoint;
    CONFIG_S3_BUCKET = homelab.storage.s3Bucket;
    CNPG_POSTGRES_IMAGE = homelab.images.cnpg;
    SNAPSHOT_CONTROLLER_IMAGE = homelab.images.snapshotController;
    VELERO_AWS_PLUGIN_IMAGE = homelab.images.veleroAwsPlugin;
    KEYCLOAK_IMAGE = homelab.images.keycloak;
    VAULTWARDEN_IMAGE = homelab.images.vaultwarden;
    HOMEPAGE_IMAGE = homelab.images.homepage;
    UPTIME_KUMA_IMAGE = homelab.images.uptimeKuma;
    SENTINEL_API_IMAGE = homelab.images.sentinelApi;
    SENTINEL_WORKER_IMAGE = homelab.images.sentinelWorker;
  };
  names = builtins.attrNames replacements;
  from = map (name: "\${${name}}") names;
  to = map (name: replacements.${name}) names;
  substitute =
    value:
    if builtins.isString value then
      builtins.replaceStrings from to value
    else if builtins.isList value then
      map substitute value
    else if builtins.isAttrs value then
      lib.mapAttrs (_: substitute) value
    else
      value;
in
substitute
