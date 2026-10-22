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
    # No globally reachable TCP listener. Administrative SSH and Kubernetes API
    # traffic are accepted only from the declared administration network, while
    # the remaining control-plane ports are restricted to the three peers.
    allowedTCPPorts = [ ];
    extraInputRules = lib.concatStringsSep "\n" (
      map (
        address:
        "ip saddr ${address} tcp dport { ${
          lib.concatMapStringsSep ", " toString peerTcpPorts
        } } accept comment \"k3s peer\""
      ) peerAddresses
      ++ [
        "ip saddr ${config.homelab.network.adminCidr} tcp dport { 22, 6443 } accept comment \"homelab administration\""
        "ip saddr ${config.homelab.network.podCidr} accept comment \"pod network\""
        "ip saddr ${config.homelab.network.serviceCidr} accept comment \"service network\""
      ]
    );
    extraForwardRules = "counter accept comment \"Cilium forwarding\"";
  };

  environment.systemPackages = [ pkgs.audit ];
}
