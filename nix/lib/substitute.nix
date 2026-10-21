{ lib, homelab }:
let
  replacements = {
    CONFIG_DOMAIN = homelab.domain;
    CONFIG_ACME_EMAIL = homelab.acmeEmail;
    CONFIG_GITLAB_REPOSITORY_URL = homelab.repository;
    CONFIG_CONTROL_PLANE_VIP = homelab.network.controlPlaneVip;
    CONFIG_LOAD_BALANCER_POOL_START = homelab.network.loadBalancerPool.start;
    CONFIG_LOAD_BALANCER_POOL_STOP = homelab.network.loadBalancerPool.stop;
    CONFIG_PRIVATE_ROUTE_CIDR = homelab.network.privateRouteCidr;
    CONFIG_POD_CIDR = homelab.network.podCidr;
    CONFIG_SERVICE_CIDR = homelab.network.serviceCidr;
    CONFIG_LONGHORN_DISK_PATH = homelab.storage.longhornDiskPath;
    CONFIG_TIMEZONE = homelab.timezone;
    CONFIG_S3_ENDPOINT = homelab.storage.s3Endpoint;
    CONFIG_S3_BUCKET = homelab.storage.s3Bucket;
  };
  names = builtins.attrNames replacements;
  from = map (name: "\${${name}}") names;
  to = map (name: replacements.${name}) names;
  substitute = value:
    if builtins.isString value then builtins.replaceStrings from to value
    else if builtins.isList value then map substitute value
    else if builtins.isAttrs value then lib.mapAttrs (_: substitute) value
    else value;
in
substitute

