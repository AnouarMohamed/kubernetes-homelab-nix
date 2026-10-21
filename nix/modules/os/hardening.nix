{
  config,
  lib,
  pkgs,
  ...
}:
let
  peerAddresses = map (node: node.address) config.homelab.nodes;
  peerTcpPorts = [
    2379
    2380
    2381
    4240
    4244
    6443
    9100
    9962
    9963
    9964
    9965
    9966
    10250
  ];
in
{
  security.auditd.enable = true;
  services.fail2ban.enable = true;
  security.sudo.wheelNeedsPassword = true;
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.rp_filter" = 0;
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
    # Global ports are limited to SSH and the API; application ingress is via
    # Cloudflare Tunnel and Cilium, never an inbound router port.
    allowedTCPPorts = [
      22
      6443
    ];
    extraInputRules = lib.concatStringsSep "\n" (
      map (
        address:
        "ip saddr ${address} tcp dport { ${
          lib.concatMapStringsSep ", " toString peerTcpPorts
        } } accept comment \"k3s peer\""
      ) peerAddresses
      ++ [
        "ip saddr ${config.homelab.network.podCidr} accept comment \"pod network\""
        "ip saddr ${config.homelab.network.serviceCidr} accept comment \"service network\""
      ]
    );
    extraForwardRules = "counter accept comment \"Cilium forwarding\"";
  };

  environment.systemPackages = [ pkgs.audit ];
}
