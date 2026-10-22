let
  hardwareProfile = {
    cpuModel = "Intel Core i7-8650U";
    cores = 4;
    threads = 8;
    memoryGiB = 32;
    diskModel = "Geonix Supersonic 512GB";
    diskSizeGB = 512;
    installDisk = "/dev/disk/by-path/pci-0000:00:17.0-ata-3";
    interface = "enp0s31f6";
  };
in
{
  # The committed profile is a runnable, private-LAN reference. Public DNS,
  # ACME, Cloudflare and encrypted secrets are supplied by a private module.
  domain = "lab.home.arpa";
  acmeEmail = "ops@lab.home.arpa";
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
    adminCidr = "10.10.0.0/24";
    privateRouteCidr = "10.10.0.0/24";
    podCidr = "10.42.0.0/16";
    serviceCidr = "10.43.0.0/16";
    controlPlaneVip = "10.10.0.10";
    loadBalancerPool = {
      start = "10.10.0.20";
      stop = "10.10.0.39";
    };
  };

  nodes = [
    {
      name = "node1";
      address = "10.10.0.11";
      inherit (hardwareProfile) interface installDisk;
      clusterInit = true;
    }
    {
      name = "node2";
      address = "10.10.0.12";
      inherit (hardwareProfile) interface installDisk;
      clusterInit = false;
    }
    {
      name = "node3";
      address = "10.10.0.13";
      inherit (hardwareProfile) interface installDisk;
      clusterInit = false;
    }
  ];

  storage = {
    defaultClass = "longhorn";
    databaseClass = "longhorn-database";
    longhornDiskPath = "/var/lib/longhorn";
    s3Endpoint = "http://minio.storage.svc.cluster.local:9000";
    s3Bucket = "homelab-backups";
  };

  replicas = {
    controlPlane = 3;
    platform = 2;
    databases = 3;
  };

  inherit hardwareProfile;
  sshAuthorizedKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBL8S/X6p5keaSfccTIWn3X79hRZkhm/cBvrH5UnN4n m.anouar@mundiapolis.ma";
  ageRecipient = null;
  sopsFile = null;
  hostTunnel = {
    # Application ingress is owned by the Kubernetes cloudflared deployment.
    # Enable a host tunnel only for a separately provisioned private-route
    # tunnel; reusing the application tunnel would create two control planes.
    enable = false;
    tunnelId = null;
  };

  images = {
    cnpg = "ghcr.io/cloudnative-pg/postgresql:17.6-system-trixie@sha256:6ae4a22c14bdc66e5feaafd38d12c3956fabf9ce9582189e6aa4ee767d981d1b";
    snapshotController = "registry.k8s.io/sig-storage/snapshot-controller:v8.6.0@sha256:81e79f205083f105e573ba2ebfe5964ede7f69a154e8627f53ebbbccd3ed9f70";
    veleroAwsPlugin = "docker.io/velero/velero-plugin-for-aws:v1.14.4@sha256:c85a7fa803569e3128c33e4f5766f84ab156c8d171c9f1dd2715581d45ce98fa";
    keycloak = "quay.io/keycloak/keycloak:26.8.0@sha256:27b3230fbabb8c9ff3c66c864cf09dcd8a41aca82e5100679d109ef0eeb05741";
    vaultwarden = "docker.io/vaultwarden/server:1.37.4-alpine@sha256:19ea2b669945d842dadc3d500f2d6a795866a003330f59a47b9634658bae98bb";
    homepage = "ghcr.io/gethomepage/homepage:v2.5.0@sha256:57c4a0531937889c0b968b120fe9c2560bbe036b5c9e18c49a9e2479de9975d1";
    uptimeKuma = "docker.io/louislam/uptime-kuma:2.5.5-rootless@sha256:c4e17ce033deb811aff8a61a5f8f736f35b1bd937458ddeec46c59ca190f0e03";
    sentinelApi = "ghcr.io/anouarmohamed/homelab-sentinel-api:v0.3.0@sha256:6f388902b07391c9b78154bab0aa1e93655a2070a1ecf1ad7a284d6cd40eaddb";
    sentinelWorker = "ghcr.io/anouarmohamed/homelab-sentinel-worker:v0.3.0@sha256:065d789e6cd7c2cbecee979e636920e35c3ed19477ded3f7122c00babe48e253";
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
