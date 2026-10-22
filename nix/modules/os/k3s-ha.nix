{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab;
  node = lib.findFirst (
    item: item.name == config.networking.hostName
  ) (builtins.head cfg.nodes) cfg.nodes;
in
{
  services.k3s = {
    enable = true;
    # nixpkgs at the locked revision exposes 1.35.8+k3s1 here. Pin the
    # attribute explicitly so a future default alias cannot silently move the
    # control plane to a different Kubernetes minor.
    package = pkgs.k3s_1_35;
    role = "server";
    inherit (node) clusterInit;
    serverAddr = if node.clusterInit then "" else "https://${cfg.network.controlPlaneVip}:6443";
    tokenFile =
      if cfg.sopsFile != null then
        config.sops.secrets.k3s-token.path
      else
        "/var/lib/homelab-secrets/k3s-token";
    nodeName = node.name;
    nodeIP = node.address;
    disable = [
      "local-storage"
      "servicelb"
      "traefik"
    ];
    extraFlags = [
      "--advertise-address=${node.address}"
      "--tls-san=${cfg.network.controlPlaneVip}"
      "--tls-san=${node.name}"
      "--flannel-backend=none"
      "--disable-kube-proxy"
      "--disable-network-policy"
      "--secrets-encryption"
      "--protect-kernel-defaults"
      "--etcd-expose-metrics"
      "--cluster-cidr=${cfg.network.podCidr}"
      "--service-cidr=${cfg.network.serviceCidr}"
      "--kubelet-arg=read-only-port=0"
      "--etcd-snapshot-schedule-cron=0 */6 * * *"
      "--etcd-snapshot-retention=28"
      "--write-kubeconfig-mode=0600"
    ];
  };
}
