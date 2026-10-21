# One-time conversion from:
# - /home/anouar/kubernetes-homelab/platform/velero/resources/allow-monitoring-scrapes.yaml
# - /home/anouar/kubernetes-homelab/platform/velero/resources/restrict-backup-controller-network.yaml
# - /home/anouar/kubernetes-homelab/platform/velero/resources/restrict-backup-controller-network.yaml
[
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-monitoring-scrapes";
      namespace = "velero";
      labels = {
        "app.kubernetes.io/name" = "velero-network";
        "app.kubernetes.io/component" = "metrics";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "velero";
        };
      };
      policyTypes = [
        "Ingress"
      ];
      ingress = [
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "monitoring";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 8085;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "deny-ingress-by-default";
      namespace = "velero";
      labels = {
        "app.kubernetes.io/name" = "velero-network";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-backup-operation";
      namespace = "velero";
      labels = {
        "app.kubernetes.io/name" = "velero-network";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Egress"
      ];
      egress = [
        {
          to = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "kube-system";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "UDP";
              port = 53;
            }
            {
              protocol = "TCP";
              port = 53;
            }
          ];
        }
        {
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
            {
              protocol = "TCP";
              port = 6443;
            }
          ];
        }
      ];
    };
  }
]
