{ config, lib, ... }:
let
  cfg = config.homelab;
  node = lib.findFirst (
    item: item.name == config.networking.hostName
  ) (builtins.head cfg.nodes) cfg.nodes;
in
{
  # kube-vip needs NET_ADMIN/NET_RAW to own the control-plane ARP VIP. It is the
  # only privileged network workload installed directly by k3s.
  services.k3s.manifests.kube-vip.content = {
    apiVersion = "v1";
    kind = "Pod";
    metadata = {
      name = "kube-vip";
      namespace = "kube-system";
    };
    spec = {
      hostNetwork = true;
      priorityClassName = "system-node-critical";
      containers = [
        {
          name = "kube-vip";
          image = "ghcr.io/kube-vip/kube-vip:v1.2.4@sha256:dde4c0669d9058c74c69c0bc2f0122e26900e1e4b913c03577cb6e4e28083079";
          args = [ "manager" ];
          env =
            map
              (pair: {
                inherit (pair) name;
                inherit (pair) value;
              })
              [
                {
                  name = "cp_enable";
                  value = "true";
                }
                {
                  name = "cp_namespace";
                  value = "kube-system";
                }
                {
                  name = "svc_enable";
                  value = "false";
                }
                {
                  name = "vip_address";
                  value = cfg.network.controlPlaneVip;
                }
                {
                  name = "vip_interface";
                  value = node.interface;
                }
                {
                  name = "vip_arp";
                  value = "true";
                }
                {
                  name = "vip_leaderelection";
                  value = "true";
                }
                {
                  name = "vip_leaseduration";
                  value = "5";
                }
                {
                  name = "vip_renewdeadline";
                  value = "3";
                }
                {
                  name = "vip_retryperiod";
                  value = "1";
                }
              ];
          securityContext.capabilities.add = [
            "NET_ADMIN"
            "NET_RAW"
          ];
          volumeMounts = [
            {
              name = "kubeconfig";
              mountPath = "/etc/kubernetes/admin.conf";
              readOnly = true;
            }
          ];
        }
      ];
      volumes = [
        {
          name = "kubeconfig";
          hostPath = {
            path = "/etc/rancher/k3s/k3s.yaml";
            type = "File";
          };
        }
      ];
    };
  };
}
