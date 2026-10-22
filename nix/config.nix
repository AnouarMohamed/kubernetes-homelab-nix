{
  domain = "placeholder.example.invalid";
  acmeEmail = "admin@placeholder.example.invalid";
  timezone = "Africa/Casablanca";
  adminUser = "operator";
  repository = "https://github.com/AnouarMohamed/kubernetes-homelab-nix.git";
  projectPath = "AnouarMohamed/kubernetes-homelab-nix";
  registryPath = "ghcr.io/anouarmohamed";
  ciIdentity = "https://github.com/AnouarMohamed/kubernetes-homelab-nix/.github/workflows/ci.yaml@refs/heads/main";

  # Keep the control-plane package, Helm capabilities, kubenix declarations,
  # Pod Security labels, and schema bundle on one explicitly pinned minor.
  kubernetes = {
    version = "1.35.8";
    minor = "1.35";
  };

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
    {
      name = "node1";
      address = "192.0.2.11";
      interface = "enp1s0";
      installDisk = "/dev/disk/by-id/REPLACE_WITH_NODE1_INSTALL_DISK";
      clusterInit = true;
    }
    {
      name = "node2";
      address = "192.0.2.12";
      interface = "enp1s0";
      installDisk = "/dev/disk/by-id/REPLACE_WITH_NODE2_INSTALL_DISK";
      clusterInit = false;
    }
    {
      name = "node3";
      address = "192.0.2.13";
      interface = "enp1s0";
      installDisk = "/dev/disk/by-id/REPLACE_WITH_NODE3_INSTALL_DISK";
      clusterInit = false;
    }
  ];

  storage = {
    defaultClass = "longhorn";
    databaseClass = "longhorn-database";
    longhornDiskPath = "/var/lib/longhorn";
    s3Endpoint = "https://s3.placeholder.example.invalid";
    s3Bucket = "placeholder-homelab-backups";
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
  hostTunnel = {
    # Application ingress is owned by the Kubernetes cloudflared deployment.
    # Enable a host tunnel only for a separately provisioned private-route
    # tunnel; reusing the application tunnel would create two control planes.
    enable = false;
    tunnelId = "REPLACE_WITH_HOST_TUNNEL_ID";
  };

  images = {
    cnpg = "ghcr.io/cloudnative-pg/postgresql:17.6-system-trixie@sha256:6ae4a22c14bdc66e5feaafd38d12c3956fabf9ce9582189e6aa4ee767d981d1b";
    snapshotController = "registry.k8s.io/sig-storage/snapshot-controller:v8.6.0@sha256:81e79f205083f105e573ba2ebfe5964ede7f69a154e8627f53ebbbccd3ed9f70";
    veleroAwsPlugin = "docker.io/velero/velero-plugin-for-aws:v1.14.4@sha256:c85a7fa803569e3128c33e4f5766f84ab156c8d171c9f1dd2715581d45ce98fa";
    keycloak = "quay.io/keycloak/keycloak:26.8.0@sha256:27b3230fbabb8c9ff3c66c864cf09dcd8a41aca82e5100679d109ef0eeb05741";
    vaultwarden = "docker.io/vaultwarden/server:1.37.4-alpine@sha256:19ea2b669945d842dadc3d500f2d6a795866a003330f59a47b9634658bae98bb";
    homepage = "ghcr.io/gethomepage/homepage:v2.5.0@sha256:57c4a0531937889c0b968b120fe9c2560bbe036b5c9e18c49a9e2479de9975d1";
    uptimeKuma = "docker.io/louislam/uptime-kuma:2.5.5-rootless@sha256:c4e17ce033deb811aff8a61a5f8f736f35b1bd937458ddeec46c59ca190f0e03";
    sentinelApi = "ghcr.io/anouarmohamed/homelab-sentinel-api:v0.2.0@sha256:f1eb00311802274322d43920d811fc44a4581396d5867b37364fab0707c41d66";
    sentinelWorker = "ghcr.io/anouarmohamed/homelab-sentinel-worker:v0.2.0@sha256:169ed481ed3482b6ecca79f31aadd25caece37deb9f89e1e0ab3c5d1fc54f4f2";
  };

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
