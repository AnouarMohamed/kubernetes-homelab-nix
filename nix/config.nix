{
  domain = "PLACEHOLDER.example.invalid";
  acmeEmail = "admin@PLACEHOLDER.example.invalid";
  timezone = "Africa/Casablanca";
  repository = "https://github.com/AnouarMohamed/kubernetes-homelab-nix.git";

  network = {
    adminCidr = "192.0.2.0/24";
    privateRouteCidr = "192.0.2.0/24";
    podCidr = "10.42.0.0/16";
    serviceCidr = "10.43.0.0/16";
    controlPlaneVip = "192.0.2.10";
    loadBalancerPool = {
      start = "192.0.2.20";
      stop = "192.0.2.39";
    };
  };

  nodes = [
    { name = "node1"; address = "192.0.2.11"; interface = "enp1s0"; clusterInit = true; }
    { name = "node2"; address = "192.0.2.12"; interface = "enp1s0"; clusterInit = false; }
    { name = "node3"; address = "192.0.2.13"; interface = "enp1s0"; clusterInit = false; }
  ];

  storage = {
    defaultClass = "longhorn";
    databaseClass = "longhorn-database";
    longhornDiskPath = "/var/lib/longhorn";
    s3Endpoint = "https://s3.PLACEHOLDER.example.invalid";
    s3Bucket = "PLACEHOLDER-homelab-backups";
  };

  replicas = {
    controlPlane = 3;
    platform = 2;
    databases = 3;
  };

  sshAuthorizedKey = "REPLACE_WITH_SSH_ED25519_PUBLIC_KEY";
  ageRecipient = "REPLACE_WITH_AGE_RECIPIENT";
  cloudflareAccountId = "REPLACE_WITH_CLOUDFLARE_ACCOUNT_ID";
  cloudflareZoneId = "REPLACE_WITH_CLOUDFLARE_ZONE_ID";

  components = {
    cilium = true;
    argocd = true;
    longhorn = true;
    cnpg = true;
    velero = true;
    openbao = true;
    externalSecrets = true;
    kyverno = true;
    observability = true;
    chaosMesh = true;
    keycloak = true;
    vaultwarden = true;
    homepage = true;
    uptimeKuma = true;
    sentinel = true;
  };
}

