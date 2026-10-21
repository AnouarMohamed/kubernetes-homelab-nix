# One-time conversion from:
# - /home/anouar/kubernetes-homelab/platform/cilium/resources/allocate-load-balancer-ips.yaml
# - /home/anouar/kubernetes-homelab/platform/cilium/resources/announce-load-balancer-ips.yaml
[
  {
    apiVersion = "cilium.io/v2";
    kind = "CiliumLoadBalancerIPPool";
    metadata = {
      name = "homelab-lan";
    };
    spec = {
      blocks = [
        {
          start = "\${CONFIG_LOAD_BALANCER_START}";
          stop = "\${CONFIG_LOAD_BALANCER_STOP}";
        }
      ];
    };
  }
  {
    apiVersion = "cilium.io/v2alpha1";
    kind = "CiliumL2AnnouncementPolicy";
    metadata = {
      name = "homelab-lan";
    };
    spec = {
      interfaces = [
        "\${CONFIG_NODE_INTERFACE_PATTERN}"
      ];
      loadBalancerIPs = true;
      externalIPs = false;
      nodeSelector = {
        matchExpressions = [
          {
            key = "node-role.kubernetes.io/control-plane";
            operator = "Exists";
          }
        ];
      };
      serviceSelector = { };
    };
  }
]
