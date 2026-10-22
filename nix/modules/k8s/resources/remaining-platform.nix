# One-time conversion from:
# - /home/anouar/kubernetes-homelab/platform/argo-rollouts/resources/allow-controller-kubernetes-api.yaml
# - /home/anouar/kubernetes-homelab/platform/argo-rollouts/resources/create-argo-rollouts-namespace.yaml
# - /home/anouar/kubernetes-homelab/platform/argo-rollouts/resources/restrict-argo-rollouts-network.yaml
# - /home/anouar/kubernetes-homelab/platform/cert-manager/resources/issue-public-certificates.yaml
# - /home/anouar/kubernetes-homelab/platform/cert-manager/resources/issue-staging-certificates.yaml
# - /home/anouar/kubernetes-homelab/platform/cert-manager/resources/request-edge-certificate.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/create-chaos-namespaces.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/create-chaos-namespaces.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/deploy-chaos-target.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/deploy-chaos-target.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/preserve-chaos-controller-availability.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/preserve-chaos-target-availability.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/restrict-chaos-controller-network.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/resources/restrict-chaos-target-network.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/experiments/delay-filesystem-io.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/experiments/impair-network.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/experiments/impair-network.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/experiments/stress-cpu.yaml
# - /home/anouar/kubernetes-homelab/platform/chaos-mesh/experiments/terminate-one-pod.yaml
# - /home/anouar/kubernetes-homelab/platform/external-dns/resources/restrict-network-access.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudflared/create-cloudflare-namespace.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudflared/deploy-cloudflare-tunnel.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudflared/preserve-cloudflare-tunnel-availability.yaml
# - /home/anouar/kubernetes-homelab/platform/cloudflared/restrict-cloudflare-tunnel-network.yaml
# - /home/anouar/kubernetes-homelab/platform/gateways/create-gateway-namespace.yaml
# - /home/anouar/kubernetes-homelab/platform/gateways/expose-internal-services.yaml
# - /home/anouar/kubernetes-homelab/platform/gateways/expose-public-services.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/harden-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/restrict-snapshot-controller-network.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/authorize-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/authorize-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/authorize-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/authorize-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/authorize-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/define-volume-snapshotclasses.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/define-volume-snapshotcontents.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/define-volume-snapshots.yaml
# - /home/anouar/kubernetes-homelab/platform/snapshot-controller/upstream/deploy-snapshot-controller.yaml
# - /home/anouar/kubernetes-homelab/platform/storage-verification/verify-volume-survives-reschedule.yaml
# - /home/anouar/kubernetes-homelab/platform/storage-verification/verify-volume-survives-reschedule.yaml
# - /home/anouar/kubernetes-homelab/platform/storage-verification/verify-volume-survives-reschedule.yaml
# - /home/anouar/kubernetes-homelab/platform/network-policies/components/default-deny/allow-dns-egress.yaml
# - /home/anouar/kubernetes-homelab/platform/network-policies/components/default-deny/allow-intra-namespace.yaml
# - /home/anouar/kubernetes-homelab/platform/network-policies/components/default-deny/deny-egress-by-default.yaml
# - /home/anouar/kubernetes-homelab/platform/network-policies/components/default-deny/deny-ingress-by-default.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/authorize-openbao-authentication.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/connect-external-secrets-to-openbao.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
# - /home/anouar/kubernetes-homelab/platform/runtime-secrets/replicate-openbao-ca.yaml
[
  {
    apiVersion = "cilium.io/v2";
    kind = "CiliumNetworkPolicy";
    metadata = {
      name = "allow-controller-kubernetes-api";
      namespace = "argo-rollouts";
      labels = {
        "app.kubernetes.io/name" = "argo-rollouts";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "homelab-platform";
      };
    };
    spec = {
      endpointSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "argo-rollouts";
        };
      };
      egress = [
        {
          toEntities = [
            "kube-apiserver"
          ];
        }
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "argo-rollouts";
      labels = {
        "app.kubernetes.io/name" = "argo-rollouts";
        "app.kubernetes.io/component" = "progressive-delivery";
        "app.kubernetes.io/part-of" = "homelab-platform";
        "pod-security.kubernetes.io/enforce" = "restricted";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "argo-rollouts-controller";
      namespace = "argo-rollouts";
      labels = {
        "app.kubernetes.io/name" = "argo-rollouts";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "homelab-platform";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "argo-rollouts";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
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
              port = 8090;
              protocol = "TCP";
            }
          ];
        }
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
              port = 53;
              protocol = "UDP";
            }
            {
              port = 53;
              protocol = "TCP";
            }
          ];
        }
        {
          to = [
            {
              ipBlock = {
                cidr = "0.0.0.0/0";
              };
            }
          ];
          ports = [
            {
              port = 443;
              protocol = "TCP";
            }
          ];
        }
        {
          to = [
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
              port = 9090;
              protocol = "TCP";
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "cert-manager.io/v1";
    kind = "ClusterIssuer";
    metadata = {
      name = "letsencrypt-production";
      annotations = {
        "argocd.argoproj.io/sync-wave" = "1";
      };
      labels = {
        "app.kubernetes.io/name" = "letsencrypt-production";
        "app.kubernetes.io/component" = "certificate-issuer";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      acme = {
        email = "\${CONFIG_ACME_EMAIL}";
        server = "https://acme-v02.api.letsencrypt.org/directory";
        privateKeySecretRef = {
          name = "letsencrypt-production-account";
        };
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token";
                  key = "api-token";
                };
              };
            };
            selector = {
              dnsZones = [
                "\${CONFIG_DOMAIN}"
              ];
            };
          }
        ];
      };
    };
  }
  {
    apiVersion = "cert-manager.io/v1";
    kind = "ClusterIssuer";
    metadata = {
      name = "letsencrypt-staging";
      annotations = {
        "argocd.argoproj.io/sync-wave" = "1";
      };
      labels = {
        "app.kubernetes.io/name" = "letsencrypt-staging";
        "app.kubernetes.io/component" = "certificate-issuer";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      acme = {
        email = "\${CONFIG_ACME_EMAIL}";
        server = "https://acme-staging-v02.api.letsencrypt.org/directory";
        privateKeySecretRef = {
          name = "letsencrypt-staging-account";
        };
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token";
                  key = "api-token";
                };
              };
            };
            selector = {
              dnsZones = [
                "\${CONFIG_DOMAIN}"
              ];
            };
          }
        ];
      };
    };
  }
  {
    apiVersion = "cert-manager.io/v1";
    kind = "Certificate";
    metadata = {
      name = "edge-wildcard";
      namespace = "gateways";
      annotations = {
        "argocd.argoproj.io/sync-wave" = "2";
      };
      labels = {
        "app.kubernetes.io/name" = "edge-wildcard";
        "app.kubernetes.io/component" = "certificate";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      secretName = "edge-wildcard-tls";
      issuerRef = {
        group = "cert-manager.io";
        kind = "ClusterIssuer";
        name = "letsencrypt-production";
      };
      dnsNames = [
        "\${CONFIG_DOMAIN}"
        "*.\${CONFIG_DOMAIN}"
        "*.internal.\${CONFIG_DOMAIN}"
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "chaos-mesh";
      labels = {
        "app.kubernetes.io/name" = "chaos-mesh";
        "app.kubernetes.io/component" = "controller";
        "app.kubernetes.io/part-of" = "resilience-testing";
        "policy.homelab.dev/profile" = "infrastructure";
        "pod-security.kubernetes.io/enforce" = "privileged";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "chaos-testing";
      annotations = {
        "chaos-mesh.org/inject" = "enabled";
      };
      labels = {
        "app.kubernetes.io/name" = "chaos-testing";
        "app.kubernetes.io/component" = "test-namespace";
        "app.kubernetes.io/part-of" = "resilience-testing";
        "policy.homelab.dev/profile" = "application";
        "pod-security.kubernetes.io/enforce" = "restricted";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "chaos-target";
      namespace = "chaos-testing";
      labels = {
        "app.kubernetes.io/name" = "chaos-target";
        "app.kubernetes.io/component" = "sacrificial-workload";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      replicas = 3;
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "chaos-target";
        };
      };
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "chaos-target";
            "app.kubernetes.io/component" = "sacrificial-workload";
            "app.kubernetes.io/part-of" = "resilience-testing";
            "chaos.homelab.dev/target" = "enabled";
          };
        };
        spec = {
          automountServiceAccountToken = false;
          securityContext = {
            runAsNonRoot = true;
            runAsUser = 65532;
            runAsGroup = 65532;
            seccompProfile = {
              type = "RuntimeDefault";
            };
          };
          affinity = {
            podAntiAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = [
                {
                  topologyKey = "kubernetes.io/hostname";
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "chaos-target";
                    };
                  };
                }
              ];
            };
          };
          containers = [
            {
              name = "chaos-target";
              image = "docker.io/traefik/whoami:v1.11.0@sha256:200689790a0a0ea48ca45992e0450bc26ccab5307375b41c84dfc4f2475937ab";
              imagePullPolicy = "IfNotPresent";
              ports = [
                {
                  name = "http";
                  containerPort = 80;
                  protocol = "TCP";
                }
              ];
              readinessProbe = {
                httpGet = {
                  path = "/health";
                  port = "http";
                };
                initialDelaySeconds = 2;
                periodSeconds = 5;
              };
              livenessProbe = {
                httpGet = {
                  path = "/health";
                  port = "http";
                };
                initialDelaySeconds = 10;
                periodSeconds = 15;
              };
              resources = {
                requests = {
                  cpu = "20m";
                  memory = "24Mi";
                };
                limits = {
                  cpu = "250m";
                  memory = "96Mi";
                };
              };
              securityContext = {
                allowPrivilegeEscalation = false;
                capabilities = {
                  drop = [
                    "ALL"
                  ];
                };
                readOnlyRootFilesystem = true;
                runAsNonRoot = true;
                seccompProfile = {
                  type = "RuntimeDefault";
                };
              };
              volumeMounts = [
                {
                  name = "data";
                  mountPath = "/data";
                }
              ];
            }
          ];
          volumes = [
            {
              name = "data";
              emptyDir = { };
            }
          ];
        };
      };
    };
  }
  {
    apiVersion = "v1";
    kind = "Service";
    metadata = {
      name = "chaos-target";
      namespace = "chaos-testing";
      labels = {
        "app.kubernetes.io/name" = "chaos-target";
        "app.kubernetes.io/component" = "sacrificial-workload";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      selector = {
        "app.kubernetes.io/name" = "chaos-target";
      };
      ports = [
        {
          name = "http";
          port = 80;
          targetPort = "http";
        }
      ];
    };
  }
  {
    apiVersion = "policy/v1";
    kind = "PodDisruptionBudget";
    metadata = {
      name = "chaos-controller-manager";
      namespace = "chaos-mesh";
      labels = {
        "app.kubernetes.io/name" = "chaos-mesh";
        "app.kubernetes.io/component" = "availability";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      minAvailable = 2;
      unhealthyPodEvictionPolicy = "AlwaysAllow";
      selector = {
        matchLabels = {
          "app.kubernetes.io/component" = "controller-manager";
        };
      };
    };
  }
  {
    apiVersion = "policy/v1";
    kind = "PodDisruptionBudget";
    metadata = {
      name = "chaos-target";
      namespace = "chaos-testing";
      labels = {
        "app.kubernetes.io/name" = "chaos-target";
        "app.kubernetes.io/component" = "availability";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      minAvailable = 1;
      unhealthyPodEvictionPolicy = "AlwaysAllow";
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "chaos-target";
        };
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "chaos-mesh-control-plane";
      namespace = "chaos-mesh";
      labels = {
        "app.kubernetes.io/name" = "chaos-mesh";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          ports = [
            {
              port = 10250;
              protocol = "TCP";
            }
          ];
        }
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "chaos-mesh";
                };
              };
            }
          ];
        }
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
              port = 10080;
              protocol = "TCP";
            }
          ];
        }
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
              port = 53;
              protocol = "UDP";
            }
            {
              port = 53;
              protocol = "TCP";
            }
          ];
        }
        {
          ports = [
            {
              port = 6443;
              protocol = "TCP";
            }
          ];
        }
        {
          to = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "chaos-mesh";
                };
              };
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
      name = "chaos-target";
      namespace = "chaos-testing";
      labels = {
        "app.kubernetes.io/name" = "chaos-target";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "chaos-target";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "chaos-testing";
                };
              };
            }
          ];
          ports = [
            {
              port = 80;
              protocol = "TCP";
            }
          ];
        }
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
              port = 53;
              protocol = "UDP";
            }
            {
              port = 53;
              protocol = "TCP";
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "chaos-mesh.org/v1alpha1";
    kind = "IOChaos";
    metadata = {
      name = "delay-target-filesystem";
      labels = {
        "app.kubernetes.io/name" = "delay-target-filesystem";
        "app.kubernetes.io/component" = "chaos-experiment";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      action = "latency";
      mode = "one";
      duration = "2m";
      selector = {
        namespaces = [
          "chaos-testing"
        ];
        labelSelectors = {
          "chaos.homelab.dev/target" = "enabled";
        };
      };
      volumePath = "/data";
      path = "**/*";
      delay = "100ms";
      percent = 50;
      containerNames = [
        "chaos-target"
      ];
    };
  }
  {
    apiVersion = "chaos-mesh.org/v1alpha1";
    kind = "NetworkChaos";
    metadata = {
      name = "delay-target-network";
      labels = {
        "app.kubernetes.io/name" = "delay-target-network";
        "app.kubernetes.io/component" = "chaos-experiment";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      action = "delay";
      mode = "one";
      duration = "2m";
      direction = "both";
      selector = {
        namespaces = [
          "chaos-testing"
        ];
        labelSelectors = {
          "chaos.homelab.dev/target" = "enabled";
        };
      };
      delay = {
        latency = "250ms";
        jitter = "50ms";
        correlation = "50";
      };
    };
  }
  {
    apiVersion = "chaos-mesh.org/v1alpha1";
    kind = "NetworkChaos";
    metadata = {
      name = "partition-target-peers";
      labels = {
        "app.kubernetes.io/name" = "partition-target-peers";
        "app.kubernetes.io/component" = "chaos-experiment";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      action = "partition";
      mode = "one";
      duration = "1m";
      direction = "both";
      selector = {
        namespaces = [
          "chaos-testing"
        ];
        labelSelectors = {
          "chaos.homelab.dev/target" = "enabled";
        };
      };
      target = {
        mode = "all";
        selector = {
          namespaces = [
            "chaos-testing"
          ];
          labelSelectors = {
            "chaos.homelab.dev/target" = "enabled";
          };
        };
      };
    };
  }
  {
    apiVersion = "chaos-mesh.org/v1alpha1";
    kind = "StressChaos";
    metadata = {
      name = "stress-one-target-cpu";
      labels = {
        "app.kubernetes.io/name" = "stress-one-target-cpu";
        "app.kubernetes.io/component" = "chaos-experiment";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      mode = "one";
      duration = "2m";
      selector = {
        namespaces = [
          "chaos-testing"
        ];
        labelSelectors = {
          "chaos.homelab.dev/target" = "enabled";
        };
      };
      stressors = {
        cpu = {
          workers = 1;
          load = 80;
        };
      };
    };
  }
  {
    apiVersion = "chaos-mesh.org/v1alpha1";
    kind = "PodChaos";
    metadata = {
      name = "terminate-one-target";
      labels = {
        "app.kubernetes.io/name" = "terminate-one-target";
        "app.kubernetes.io/component" = "chaos-experiment";
        "app.kubernetes.io/part-of" = "resilience-testing";
      };
    };
    spec = {
      action = "pod-kill";
      mode = "one";
      duration = "30s";
      selector = {
        namespaces = [
          "chaos-testing"
        ];
        labelSelectors = {
          "chaos.homelab.dev/target" = "enabled";
        };
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "external-dns-egress";
      namespace = "external-dns";
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "external-dns";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "observability";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 7979;
            }
          ];
        }
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
          to = [
            {
              ipBlock = {
                cidr = "0.0.0.0/0";
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "cloudflare";
      labels = {
        "app.kubernetes.io/name" = "cloudflare";
        "app.kubernetes.io/component" = "tunnel";
        "app.kubernetes.io/part-of" = "edge-access";
        "pod-security.kubernetes.io/enforce" = "restricted";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "cloudflared";
      namespace = "cloudflare";
      labels = {
        "app.kubernetes.io/name" = "cloudflared";
        "app.kubernetes.io/component" = "tunnel";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      replicas = 2;
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "cloudflared";
        };
      };
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "cloudflared";
            "app.kubernetes.io/component" = "tunnel";
            "app.kubernetes.io/part-of" = "edge-access";
          };
        };
        spec = {
          automountServiceAccountToken = false;
          securityContext = {
            runAsNonRoot = true;
            runAsUser = 65532;
            runAsGroup = 65532;
            fsGroup = 65532;
            seccompProfile = {
              type = "RuntimeDefault";
            };
          };
          affinity = {
            podAntiAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = [
                {
                  topologyKey = "kubernetes.io/hostname";
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "cloudflared";
                    };
                  };
                }
              ];
            };
          };
          topologySpreadConstraints = [
            {
              maxSkew = 1;
              topologyKey = "kubernetes.io/hostname";
              whenUnsatisfiable = "DoNotSchedule";
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "cloudflared";
                };
              };
            }
          ];
          containers = [
            {
              name = "cloudflared";
              image = "docker.io/cloudflare/cloudflared:2026.10.0@sha256:9b49eed8f62806d5d45ddf59ecefb5710429598ea6d3fcccd2af938f621b2b07";
              imagePullPolicy = "IfNotPresent";
              args = [
                "tunnel"
                "--no-autoupdate"
                "--metrics"
                "0.0.0.0:2000"
                "run"
                "--token-file"
                "/etc/cloudflared/token"
              ];
              ports = [
                {
                  name = "metrics";
                  containerPort = 2000;
                  protocol = "TCP";
                }
              ];
              readinessProbe = {
                httpGet = {
                  path = "/ready";
                  port = "metrics";
                };
                initialDelaySeconds = 10;
                periodSeconds = 10;
              };
              livenessProbe = {
                httpGet = {
                  path = "/ready";
                  port = "metrics";
                };
                initialDelaySeconds = 30;
                periodSeconds = 30;
              };
              securityContext = {
                allowPrivilegeEscalation = false;
                capabilities = {
                  drop = [
                    "ALL"
                  ];
                };
                readOnlyRootFilesystem = true;
              };
              resources = {
                requests = {
                  cpu = "50m";
                  memory = "64Mi";
                };
                limits = {
                  cpu = "500m";
                  memory = "256Mi";
                };
              };
              volumeMounts = [
                {
                  name = "tunnel-token";
                  mountPath = "/etc/cloudflared";
                  readOnly = true;
                }
                {
                  name = "tmp";
                  mountPath = "/tmp";
                }
              ];
            }
          ];
          volumes = [
            {
              name = "tunnel-token";
              secret = {
                secretName = "cloudflared-tunnel-token";
                items = [
                  {
                    key = "token";
                    path = "token";
                  }
                ];
              };
            }
            {
              name = "tmp";
              emptyDir = { };
            }
          ];
        };
      };
    };
  }
  {
    apiVersion = "policy/v1";
    kind = "PodDisruptionBudget";
    metadata = {
      name = "cloudflared";
      namespace = "cloudflare";
    };
    spec = {
      maxUnavailable = 1;
      unhealthyPodEvictionPolicy = "AlwaysAllow";
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "cloudflared";
        };
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "cloudflared";
      namespace = "cloudflare";
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "cloudflared";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          from = [
            {
              namespaceSelector = {
                matchLabels = {
                  "kubernetes.io/metadata.name" = "observability";
                };
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 2000;
            }
          ];
        }
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
              port = 80;
            }
          ];
        }
        {
          to = [
            {
              ipBlock = {
                cidr = "0.0.0.0/0";
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 443;
            }
            {
              protocol = "UDP";
              port = 7844;
            }
            {
              protocol = "TCP";
              port = 7844;
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "gateways";
      labels = {
        "app.kubernetes.io/name" = "gateways";
        "app.kubernetes.io/component" = "edge-routing";
        "app.kubernetes.io/part-of" = "edge-access";
        "pod-security.kubernetes.io/enforce" = "restricted";
        "pod-security.kubernetes.io/enforce-version" = "v1.35";
        "pod-security.kubernetes.io/audit" = "restricted";
        "pod-security.kubernetes.io/audit-version" = "v1.35";
        "pod-security.kubernetes.io/warn" = "restricted";
        "pod-security.kubernetes.io/warn-version" = "v1.35";
      };
    };
  }
  {
    apiVersion = "gateway.networking.k8s.io/v1";
    kind = "Gateway";
    metadata = {
      name = "internal";
      namespace = "gateways";
      labels = {
        "app.kubernetes.io/name" = "internal-gateway";
        "app.kubernetes.io/component" = "edge-routing";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      gatewayClassName = "cilium";
      addresses = [
        {
          type = "IPAddress";
          value = "\${CONFIG_LOAD_BALANCER_START}";
        }
      ];
      listeners = [
        {
          name = "https";
          protocol = "HTTPS";
          port = 443;
          hostname = "*.internal.\${CONFIG_DOMAIN}";
          tls = {
            mode = "Terminate";
            certificateRefs = [
              {
                group = "";
                kind = "Secret";
                name = "edge-wildcard-tls";
              }
            ];
          };
          allowedRoutes = {
            namespaces = {
              from = "Selector";
              selector = {
                matchLabels = {
                  "homelab.anouar.dev/internal-gateway-access" = "true";
                };
              };
            };
          };
        }
      ];
    };
  }
  {
    apiVersion = "gateway.networking.k8s.io/v1";
    kind = "Gateway";
    metadata = {
      name = "public";
      namespace = "gateways";
      labels = {
        "app.kubernetes.io/name" = "public-gateway";
        "app.kubernetes.io/component" = "edge-routing";
        "app.kubernetes.io/part-of" = "edge-access";
      };
    };
    spec = {
      gatewayClassName = "cilium";
      listeners = [
        {
          name = "tunnel-http";
          protocol = "HTTP";
          port = 80;
          hostname = "*.\${CONFIG_DOMAIN}";
          allowedRoutes = {
            namespaces = {
              from = "Selector";
              selector = {
                matchLabels = {
                  "homelab.anouar.dev/public-gateway-access" = "true";
                };
              };
            };
          };
        }
        {
          name = "https";
          protocol = "HTTPS";
          port = 443;
          hostname = "*.\${CONFIG_DOMAIN}";
          tls = {
            mode = "Terminate";
            certificateRefs = [
              {
                group = "";
                kind = "Secret";
                name = "edge-wildcard-tls";
              }
            ];
          };
          allowedRoutes = {
            namespaces = {
              from = "Selector";
              selector = {
                matchLabels = {
                  "homelab.anouar.dev/public-gateway-access" = "true";
                };
              };
            };
          };
        }
      ];
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "snapshot-controller";
      namespace = "kube-system";
      labels = {
        "app.kubernetes.io/name" = "snapshot-controller";
        "app.kubernetes.io/component" = "controller";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "snapshot-controller";
            "app.kubernetes.io/component" = "controller";
            "app.kubernetes.io/part-of" = "storage";
          };
        };
        spec = {
          affinity = {
            podAntiAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = [
                {
                  topologyKey = "kubernetes.io/hostname";
                  labelSelector = {
                    matchLabels = {
                      "app.kubernetes.io/name" = "snapshot-controller";
                    };
                  };
                }
              ];
            };
          };
          securityContext = {
            runAsNonRoot = true;
            runAsUser = 65532;
            runAsGroup = 65532;
            seccompProfile = {
              type = "RuntimeDefault";
            };
          };
          containers = [
            {
              name = "snapshot-controller";
              image = "\${SNAPSHOT_CONTROLLER_IMAGE}";
              args = [
                "--v=2"
                "--leader-election=true"
                "--http-endpoint=:8080"
                "--prevent-volume-mode-conversion=true"
              ];
              ports = [
                {
                  name = "metrics";
                  containerPort = 8080;
                  protocol = "TCP";
                }
              ];
              livenessProbe = {
                httpGet = {
                  path = "/metrics";
                  port = "metrics";
                };
                initialDelaySeconds = 10;
                periodSeconds = 20;
              };
              readinessProbe = {
                httpGet = {
                  path = "/metrics";
                  port = "metrics";
                };
                initialDelaySeconds = 5;
                periodSeconds = 10;
              };
              resources = {
                requests = {
                  cpu = "20m";
                  memory = "64Mi";
                };
                limits = {
                  cpu = "300m";
                  memory = "256Mi";
                };
              };
              securityContext = {
                allowPrivilegeEscalation = false;
                capabilities = {
                  drop = [
                    "ALL"
                  ];
                };
                readOnlyRootFilesystem = true;
              };
            }
          ];
        };
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "restrict-snapshot-controller";
      namespace = "kube-system";
      labels = {
        "app.kubernetes.io/name" = "snapshot-controller";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "snapshot-controller";
        };
      };
      policyTypes = [
        "Ingress"
        "Egress"
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
              port = 8080;
            }
          ];
        }
      ];
      egress = [
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
  {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "snapshot-controller";
      namespace = "kube-system";
    };
  }
  {
    kind = "ClusterRole";
    apiVersion = "rbac.authorization.k8s.io/v1";
    metadata = {
      name = "snapshot-controller-runner";
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "persistentvolumes"
        ];
        verbs = [
          "get"
          "list"
          "watch"
        ];
      }
      {
        apiGroups = [
          ""
        ];
        resources = [
          "persistentvolumeclaims"
        ];
        verbs = [
          "get"
          "list"
          "watch"
          "update"
        ];
      }
      {
        apiGroups = [
          ""
        ];
        resources = [
          "events"
        ];
        verbs = [
          "list"
          "watch"
          "create"
          "update"
          "patch"
        ];
      }
      {
        apiGroups = [
          "snapshot.storage.k8s.io"
        ];
        resources = [
          "volumesnapshotclasses"
        ];
        verbs = [
          "get"
          "list"
          "watch"
        ];
      }
      {
        apiGroups = [
          "snapshot.storage.k8s.io"
        ];
        resources = [
          "volumesnapshotcontents"
        ];
        verbs = [
          "create"
          "get"
          "list"
          "watch"
          "update"
          "delete"
          "patch"
        ];
      }
      {
        apiGroups = [
          "snapshot.storage.k8s.io"
        ];
        resources = [
          "volumesnapshotcontents/status"
        ];
        verbs = [
          "patch"
        ];
      }
      {
        apiGroups = [
          "snapshot.storage.k8s.io"
        ];
        resources = [
          "volumesnapshots"
        ];
        verbs = [
          "create"
          "get"
          "list"
          "watch"
          "update"
          "patch"
          "delete"
        ];
      }
      {
        apiGroups = [
          "snapshot.storage.k8s.io"
        ];
        resources = [
          "volumesnapshots/status"
        ];
        verbs = [
          "update"
          "patch"
        ];
      }
      {
        apiGroups = [
          "groupsnapshot.storage.k8s.io"
        ];
        resources = [
          "volumegroupsnapshotclasses"
        ];
        verbs = [
          "get"
          "list"
          "watch"
        ];
      }
      {
        apiGroups = [
          "groupsnapshot.storage.k8s.io"
        ];
        resources = [
          "volumegroupsnapshotcontents"
        ];
        verbs = [
          "create"
          "get"
          "list"
          "watch"
          "update"
          "delete"
          "patch"
        ];
      }
      {
        apiGroups = [
          "groupsnapshot.storage.k8s.io"
        ];
        resources = [
          "volumegroupsnapshotcontents/status"
        ];
        verbs = [
          "patch"
        ];
      }
      {
        apiGroups = [
          "groupsnapshot.storage.k8s.io"
        ];
        resources = [
          "volumegroupsnapshots"
        ];
        verbs = [
          "get"
          "list"
          "watch"
          "update"
          "patch"
        ];
      }
      {
        apiGroups = [
          "groupsnapshot.storage.k8s.io"
        ];
        resources = [
          "volumegroupsnapshots/status"
        ];
        verbs = [
          "update"
          "patch"
        ];
      }
    ];
  }
  {
    kind = "ClusterRoleBinding";
    apiVersion = "rbac.authorization.k8s.io/v1";
    metadata = {
      name = "snapshot-controller-role";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "snapshot-controller";
        namespace = "kube-system";
      }
    ];
    roleRef = {
      kind = "ClusterRole";
      name = "snapshot-controller-runner";
      apiGroup = "rbac.authorization.k8s.io";
    };
  }
  {
    kind = "Role";
    apiVersion = "rbac.authorization.k8s.io/v1";
    metadata = {
      name = "snapshot-controller-leaderelection";
      namespace = "kube-system";
    };
    rules = [
      {
        apiGroups = [
          "coordination.k8s.io"
        ];
        resources = [
          "leases"
        ];
        verbs = [
          "get"
          "watch"
          "list"
          "delete"
          "update"
          "create"
        ];
      }
    ];
  }
  {
    kind = "RoleBinding";
    apiVersion = "rbac.authorization.k8s.io/v1";
    metadata = {
      name = "snapshot-controller-leaderelection";
      namespace = "kube-system";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "snapshot-controller";
      }
    ];
    roleRef = {
      kind = "Role";
      name = "snapshot-controller-leaderelection";
      apiGroup = "rbac.authorization.k8s.io";
    };
  }
  {
    apiVersion = "apiextensions.k8s.io/v1";
    kind = "CustomResourceDefinition";
    metadata = {
      annotations = {
        "api-approved.kubernetes.io" = "https://github.com/kubernetes-csi/external-snapshotter/pull/814";
        "controller-gen.kubebuilder.io/version" = "v0.15.0";
      };
      name = "volumesnapshotclasses.snapshot.storage.k8s.io";
    };
    spec = {
      group = "snapshot.storage.k8s.io";
      names = {
        kind = "VolumeSnapshotClass";
        listKind = "VolumeSnapshotClassList";
        plural = "volumesnapshotclasses";
        shortNames = [
          "vsclass"
          "vsclasses"
        ];
        singular = "volumesnapshotclass";
      };
      scope = "Cluster";
      versions = [
        {
          additionalPrinterColumns = [
            {
              jsonPath = ".driver";
              name = "Driver";
              type = "string";
            }
            {
              description = "Determines whether a VolumeSnapshotContent created through the VolumeSnapshotClass should be deleted when its bound VolumeSnapshot is deleted.";
              jsonPath = ".deletionPolicy";
              name = "DeletionPolicy";
              type = "string";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshotClass specifies parameters that a underlying storage system uses when\ncreating a volume snapshot. A specific VolumeSnapshotClass is used by specifying its\nname in a VolumeSnapshot object.\nVolumeSnapshotClasses are non-namespaced";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                deletionPolicy = {
                  description = "deletionPolicy determines whether a VolumeSnapshotContent created through\nthe VolumeSnapshotClass should be deleted when its bound VolumeSnapshot is deleted.\nSupported values are \"Retain\" and \"Delete\".\n\"Retain\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are kept.\n\"Delete\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are deleted.\nRequired.";
                  enum = [
                    "Delete"
                    "Retain"
                  ];
                  type = "string";
                };
                driver = {
                  description = "driver is the name of the storage driver that handles this VolumeSnapshotClass.\nRequired.";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                metadata = {
                  type = "object";
                };
                parameters = {
                  additionalProperties = {
                    type = "string";
                  };
                  description = "parameters is a key-value map with storage driver specific parameters for creating snapshots.\nThese values are opaque to Kubernetes.";
                  type = "object";
                };
              };
              required = [
                "deletionPolicy"
                "driver"
              ];
              type = "object";
            };
          };
          served = true;
          storage = true;
          subresources = { };
        }
        {
          additionalPrinterColumns = [
            {
              jsonPath = ".driver";
              name = "Driver";
              type = "string";
            }
            {
              description = "Determines whether a VolumeSnapshotContent created through the VolumeSnapshotClass should be deleted when its bound VolumeSnapshot is deleted.";
              jsonPath = ".deletionPolicy";
              name = "DeletionPolicy";
              type = "string";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1beta1";
          deprecated = true;
          deprecationWarning = "snapshot.storage.k8s.io/v1beta1 VolumeSnapshotClass is deprecated; use snapshot.storage.k8s.io/v1 VolumeSnapshotClass";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshotClass specifies parameters that a underlying storage system uses when creating a volume snapshot. A specific VolumeSnapshotClass is used by specifying its name in a VolumeSnapshot object. VolumeSnapshotClasses are non-namespaced";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                deletionPolicy = {
                  description = "deletionPolicy determines whether a VolumeSnapshotContent created through the VolumeSnapshotClass should be deleted when its bound VolumeSnapshot is deleted. Supported values are \"Retain\" and \"Delete\". \"Retain\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are kept. \"Delete\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are deleted. Required.";
                  enum = [
                    "Delete"
                    "Retain"
                  ];
                  type = "string";
                };
                driver = {
                  description = "driver is the name of the storage driver that handles this VolumeSnapshotClass. Required.";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                parameters = {
                  additionalProperties = {
                    type = "string";
                  };
                  description = "parameters is a key-value map with storage driver specific parameters for creating snapshots. These values are opaque to Kubernetes.";
                  type = "object";
                };
              };
              required = [
                "deletionPolicy"
                "driver"
              ];
              type = "object";
            };
          };
          served = false;
          storage = false;
          subresources = { };
        }
      ];
    };
    status = {
      acceptedNames = {
        kind = "";
        plural = "";
      };
      conditions = [ ];
      storedVersions = [ ];
    };
  }
  {
    apiVersion = "apiextensions.k8s.io/v1";
    kind = "CustomResourceDefinition";
    metadata = {
      annotations = {
        "controller-gen.kubebuilder.io/version" = "v0.15.0";
        "api-approved.kubernetes.io" = "https://github.com/kubernetes-csi/external-snapshotter/pull/955";
      };
      name = "volumesnapshotcontents.snapshot.storage.k8s.io";
    };
    spec = {
      group = "snapshot.storage.k8s.io";
      names = {
        kind = "VolumeSnapshotContent";
        listKind = "VolumeSnapshotContentList";
        plural = "volumesnapshotcontents";
        shortNames = [
          "vsc"
          "vscs"
        ];
        singular = "volumesnapshotcontent";
      };
      scope = "Cluster";
      versions = [
        {
          additionalPrinterColumns = [
            {
              description = "Indicates if the snapshot is ready to be used to restore a volume.";
              jsonPath = ".status.readyToUse";
              name = "ReadyToUse";
              type = "boolean";
            }
            {
              description = "Represents the complete size of the snapshot in bytes";
              jsonPath = ".status.restoreSize";
              name = "RestoreSize";
              type = "integer";
            }
            {
              description = "Determines whether this VolumeSnapshotContent and its physical snapshot on the underlying storage system should be deleted when its bound VolumeSnapshot is deleted.";
              jsonPath = ".spec.deletionPolicy";
              name = "DeletionPolicy";
              type = "string";
            }
            {
              description = "Name of the CSI driver used to create the physical snapshot on the underlying storage system.";
              jsonPath = ".spec.driver";
              name = "Driver";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshotClass to which this snapshot belongs.";
              jsonPath = ".spec.volumeSnapshotClassName";
              name = "VolumeSnapshotClass";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshot object to which this VolumeSnapshotContent object is bound.";
              jsonPath = ".spec.volumeSnapshotRef.name";
              name = "VolumeSnapshot";
              type = "string";
            }
            {
              description = "Namespace of the VolumeSnapshot object to which this VolumeSnapshotContent object is bound.";
              jsonPath = ".spec.volumeSnapshotRef.namespace";
              name = "VolumeSnapshotNamespace";
              type = "string";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshotContent represents the actual \"on-disk\" snapshot object in the\nunderlying storage system";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                metadata = {
                  type = "object";
                };
                spec = {
                  description = "spec defines properties of a VolumeSnapshotContent created by the underlying storage system.\nRequired.";
                  properties = {
                    deletionPolicy = {
                      description = "deletionPolicy determines whether this VolumeSnapshotContent and its physical snapshot on\nthe underlying storage system should be deleted when its bound VolumeSnapshot is deleted.\nSupported values are \"Retain\" and \"Delete\".\n\"Retain\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are kept.\n\"Delete\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are deleted.\nFor dynamically provisioned snapshots, this field will automatically be filled in by the\nCSI snapshotter sidecar with the \"DeletionPolicy\" field defined in the corresponding\nVolumeSnapshotClass.\nFor pre-existing snapshots, users MUST specify this field when creating the\n VolumeSnapshotContent object.\nRequired.";
                      enum = [
                        "Delete"
                        "Retain"
                      ];
                      type = "string";
                    };
                    driver = {
                      description = "driver is the name of the CSI driver used to create the physical snapshot on\nthe underlying storage system.\nThis MUST be the same as the name returned by the CSI GetPluginName() call for\nthat driver.\nRequired.";
                      type = "string";
                    };
                    source = {
                      description = "source specifies whether the snapshot is (or should be) dynamically provisioned\nor already exists, and just requires a Kubernetes object representation.\nThis field is immutable after creation.\nRequired.";
                      properties = {
                        snapshotHandle = {
                          description = "snapshotHandle specifies the CSI \"snapshot_id\" of a pre-existing snapshot on\nthe underlying storage system for which a Kubernetes object representation\nwas (or should be) created.\nThis field is immutable.";
                          type = "string";
                          x-kubernetes-validations = [
                            {
                              message = "snapshotHandle is immutable";
                              rule = "self == oldSelf";
                            }
                          ];
                        };
                        volumeHandle = {
                          description = "volumeHandle specifies the CSI \"volume_id\" of the volume from which a snapshot\nshould be dynamically taken from.\nThis field is immutable.";
                          type = "string";
                          x-kubernetes-validations = [
                            {
                              message = "volumeHandle is immutable";
                              rule = "self == oldSelf";
                            }
                          ];
                        };
                      };
                      type = "object";
                      x-kubernetes-validations = [
                        {
                          message = "volumeHandle is required once set";
                          rule = "!has(oldSelf.volumeHandle) || has(self.volumeHandle)";
                        }
                        {
                          message = "snapshotHandle is required once set";
                          rule = "!has(oldSelf.snapshotHandle) || has(self.snapshotHandle)";
                        }
                        {
                          message = "exactly one of volumeHandle and snapshotHandle must be set";
                          rule = "(has(self.volumeHandle) && !has(self.snapshotHandle)) || (!has(self.volumeHandle) && has(self.snapshotHandle))";
                        }
                      ];
                    };
                    sourceVolumeMode = {
                      description = "SourceVolumeMode is the mode of the volume whose snapshot is taken.\nCan be either “Filesystem” or “Block”.\nIf not specified, it indicates the source volume's mode is unknown.\nThis field is immutable.\nThis field is an alpha field.";
                      type = "string";
                      x-kubernetes-validations = [
                        {
                          message = "sourceVolumeMode is immutable";
                          rule = "self == oldSelf";
                        }
                      ];
                    };
                    volumeSnapshotClassName = {
                      description = "name of the VolumeSnapshotClass from which this snapshot was (or will be)\ncreated.\nNote that after provisioning, the VolumeSnapshotClass may be deleted or\nrecreated with different set of values, and as such, should not be referenced\npost-snapshot creation.";
                      type = "string";
                    };
                    volumeSnapshotRef = {
                      description = "volumeSnapshotRef specifies the VolumeSnapshot object to which this\nVolumeSnapshotContent object is bound.\nVolumeSnapshot.Spec.VolumeSnapshotContentName field must reference to\nthis VolumeSnapshotContent's name for the bidirectional binding to be valid.\nFor a pre-existing VolumeSnapshotContent object, name and namespace of the\nVolumeSnapshot object MUST be provided for binding to happen.\nThis field is immutable after creation.\nRequired.";
                      properties = {
                        apiVersion = {
                          description = "API version of the referent.";
                          type = "string";
                        };
                        fieldPath = {
                          description = "If referring to a piece of an object instead of an entire object, this string\nshould contain a valid JSON/Go field access statement, such as desiredState.manifest.containers[2].\nFor example, if the object reference is to a container within a pod, this would take on a value like:\n\"spec.containers{name}\" (where \"name\" refers to the name of the container that triggered\nthe event) or if no container name is specified \"spec.containers[2]\" (container with\nindex 2 in this pod). This syntax is chosen only to have some well-defined way of\nreferencing a part of an object.\nTODO: this design is not final and this field is subject to change in the future.";
                          type = "string";
                        };
                        kind = {
                          description = "Kind of the referent.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                          type = "string";
                        };
                        name = {
                          description = "Name of the referent.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
                          type = "string";
                        };
                        namespace = {
                          description = "Namespace of the referent.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/";
                          type = "string";
                        };
                        resourceVersion = {
                          description = "Specific resourceVersion to which this reference is made, if any.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#concurrency-control-and-consistency";
                          type = "string";
                        };
                        uid = {
                          description = "UID of the referent.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids";
                          type = "string";
                        };
                      };
                      type = "object";
                      x-kubernetes-map-type = "atomic";
                      x-kubernetes-validations = [
                        {
                          message = "both spec.volumeSnapshotRef.name and spec.volumeSnapshotRef.namespace must be set";
                          rule = "has(self.name) && has(self.__namespace__)";
                        }
                      ];
                    };
                  };
                  required = [
                    "deletionPolicy"
                    "driver"
                    "source"
                    "volumeSnapshotRef"
                  ];
                  type = "object";
                  x-kubernetes-validations = [
                    {
                      message = "sourceVolumeMode is required once set";
                      rule = "!has(oldSelf.sourceVolumeMode) || has(self.sourceVolumeMode)";
                    }
                  ];
                };
                status = {
                  description = "status represents the current information of a snapshot.";
                  properties = {
                    creationTime = {
                      description = "creationTime is the timestamp when the point-in-time snapshot is taken\nby the underlying storage system.\nIn dynamic snapshot creation case, this field will be filled in by the\nCSI snapshotter sidecar with the \"creation_time\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"creation_time\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it.\nIf not specified, it indicates the creation time is unknown.\nThe format of this field is a Unix nanoseconds time encoded as an int64.\nOn Unix, the command `date +%s%N` returns the current time in nanoseconds\nsince 1970-01-01 00:00:00 UTC.";
                      format = "int64";
                      type = "integer";
                    };
                    error = {
                      description = "error is the last observed error during snapshot creation, if any.\nUpon success after retry, this error field will be cleared.";
                      properties = {
                        message = {
                          description = "message is a string detailing the encountered error during snapshot\ncreation if specified.\nNOTE: message may be logged, and it should not contain sensitive\ninformation.";
                          type = "string";
                        };
                        time = {
                          description = "time is the timestamp when the error was encountered.";
                          format = "date-time";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    readyToUse = {
                      description = "readyToUse indicates if a snapshot is ready to be used to restore a volume.\nIn dynamic snapshot creation case, this field will be filled in by the\nCSI snapshotter sidecar with the \"ready_to_use\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"ready_to_use\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it,\notherwise, this field will be set to \"True\".\nIf not specified, it means the readiness of a snapshot is unknown.";
                      type = "boolean";
                    };
                    restoreSize = {
                      description = "restoreSize represents the complete size of the snapshot in bytes.\nIn dynamic snapshot creation case, this field will be filled in by the\nCSI snapshotter sidecar with the \"size_bytes\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"size_bytes\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it.\nWhen restoring a volume from this snapshot, the size of the volume MUST NOT\nbe smaller than the restoreSize if it is specified, otherwise the restoration will fail.\nIf not specified, it indicates that the size is unknown.";
                      format = "int64";
                      minimum = 0;
                      type = "integer";
                    };
                    snapshotHandle = {
                      description = "snapshotHandle is the CSI \"snapshot_id\" of a snapshot on the underlying storage system.\nIf not specified, it indicates that dynamic snapshot creation has either failed\nor it is still in progress.";
                      type = "string";
                    };
                    volumeGroupSnapshotHandle = {
                      description = "VolumeGroupSnapshotHandle is the CSI \"group_snapshot_id\" of a group snapshot\non the underlying storage system.";
                      type = "string";
                    };
                  };
                  type = "object";
                };
              };
              required = [
                "spec"
              ];
              type = "object";
            };
          };
          served = true;
          storage = true;
          subresources = {
            status = { };
          };
        }
        {
          additionalPrinterColumns = [
            {
              description = "Indicates if the snapshot is ready to be used to restore a volume.";
              jsonPath = ".status.readyToUse";
              name = "ReadyToUse";
              type = "boolean";
            }
            {
              description = "Represents the complete size of the snapshot in bytes";
              jsonPath = ".status.restoreSize";
              name = "RestoreSize";
              type = "integer";
            }
            {
              description = "Determines whether this VolumeSnapshotContent and its physical snapshot on the underlying storage system should be deleted when its bound VolumeSnapshot is deleted.";
              jsonPath = ".spec.deletionPolicy";
              name = "DeletionPolicy";
              type = "string";
            }
            {
              description = "Name of the CSI driver used to create the physical snapshot on the underlying storage system.";
              jsonPath = ".spec.driver";
              name = "Driver";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshotClass to which this snapshot belongs.";
              jsonPath = ".spec.volumeSnapshotClassName";
              name = "VolumeSnapshotClass";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshot object to which this VolumeSnapshotContent object is bound.";
              jsonPath = ".spec.volumeSnapshotRef.name";
              name = "VolumeSnapshot";
              type = "string";
            }
            {
              description = "Namespace of the VolumeSnapshot object to which this VolumeSnapshotContent object is bound.";
              jsonPath = ".spec.volumeSnapshotRef.namespace";
              name = "VolumeSnapshotNamespace";
              type = "string";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1beta1";
          deprecated = true;
          deprecationWarning = "snapshot.storage.k8s.io/v1beta1 VolumeSnapshotContent is deprecated; use snapshot.storage.k8s.io/v1 VolumeSnapshotContent";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshotContent represents the actual \"on-disk\" snapshot object in the underlying storage system";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                spec = {
                  description = "spec defines properties of a VolumeSnapshotContent created by the underlying storage system. Required.";
                  properties = {
                    deletionPolicy = {
                      description = "deletionPolicy determines whether this VolumeSnapshotContent and its physical snapshot on the underlying storage system should be deleted when its bound VolumeSnapshot is deleted. Supported values are \"Retain\" and \"Delete\". \"Retain\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are kept. \"Delete\" means that the VolumeSnapshotContent and its physical snapshot on underlying storage system are deleted. For dynamically provisioned snapshots, this field will automatically be filled in by the CSI snapshotter sidecar with the \"DeletionPolicy\" field defined in the corresponding VolumeSnapshotClass. For pre-existing snapshots, users MUST specify this field when creating the  VolumeSnapshotContent object. Required.";
                      enum = [
                        "Delete"
                        "Retain"
                      ];
                      type = "string";
                    };
                    driver = {
                      description = "driver is the name of the CSI driver used to create the physical snapshot on the underlying storage system. This MUST be the same as the name returned by the CSI GetPluginName() call for that driver. Required.";
                      type = "string";
                    };
                    source = {
                      description = "source specifies whether the snapshot is (or should be) dynamically provisioned or already exists, and just requires a Kubernetes object representation. This field is immutable after creation. Required.";
                      properties = {
                        snapshotHandle = {
                          description = "snapshotHandle specifies the CSI \"snapshot_id\" of a pre-existing snapshot on the underlying storage system for which a Kubernetes object representation was (or should be) created. This field is immutable.";
                          type = "string";
                        };
                        volumeHandle = {
                          description = "volumeHandle specifies the CSI \"volume_id\" of the volume from which a snapshot should be dynamically taken from. This field is immutable.";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    volumeSnapshotClassName = {
                      description = "name of the VolumeSnapshotClass from which this snapshot was (or will be) created. Note that after provisioning, the VolumeSnapshotClass may be deleted or recreated with different set of values, and as such, should not be referenced post-snapshot creation.";
                      type = "string";
                    };
                    volumeSnapshotRef = {
                      description = "volumeSnapshotRef specifies the VolumeSnapshot object to which this VolumeSnapshotContent object is bound. VolumeSnapshot.Spec.VolumeSnapshotContentName field must reference to this VolumeSnapshotContent's name for the bidirectional binding to be valid. For a pre-existing VolumeSnapshotContent object, name and namespace of the VolumeSnapshot object MUST be provided for binding to happen. This field is immutable after creation. Required.";
                      properties = {
                        apiVersion = {
                          description = "API version of the referent.";
                          type = "string";
                        };
                        fieldPath = {
                          description = "If referring to a piece of an object instead of an entire object, this string should contain a valid JSON/Go field access statement, such as desiredState.manifest.containers[2]. For example, if the object reference is to a container within a pod, this would take on a value like: \"spec.containers{name}\" (where \"name\" refers to the name of the container that triggered the event) or if no container name is specified \"spec.containers[2]\" (container with index 2 in this pod). This syntax is chosen only to have some well-defined way of referencing a part of an object. TODO: this design is not final and this field is subject to change in the future.";
                          type = "string";
                        };
                        kind = {
                          description = "Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                          type = "string";
                        };
                        name = {
                          description = "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
                          type = "string";
                        };
                        namespace = {
                          description = "Namespace of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/";
                          type = "string";
                        };
                        resourceVersion = {
                          description = "Specific resourceVersion to which this reference is made, if any. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#concurrency-control-and-consistency";
                          type = "string";
                        };
                        uid = {
                          description = "UID of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                  };
                  required = [
                    "deletionPolicy"
                    "driver"
                    "source"
                    "volumeSnapshotRef"
                  ];
                  type = "object";
                };
                status = {
                  description = "status represents the current information of a snapshot.";
                  properties = {
                    creationTime = {
                      description = "creationTime is the timestamp when the point-in-time snapshot is taken by the underlying storage system. In dynamic snapshot creation case, this field will be filled in by the CSI snapshotter sidecar with the \"creation_time\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"creation_time\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it. If not specified, it indicates the creation time is unknown. The format of this field is a Unix nanoseconds time encoded as an int64. On Unix, the command `date +%s%N` returns the current time in nanoseconds since 1970-01-01 00:00:00 UTC.";
                      format = "int64";
                      type = "integer";
                    };
                    error = {
                      description = "error is the last observed error during snapshot creation, if any. Upon success after retry, this error field will be cleared.";
                      properties = {
                        message = {
                          description = "message is a string detailing the encountered error during snapshot creation if specified. NOTE: message may be logged, and it should not contain sensitive information.";
                          type = "string";
                        };
                        time = {
                          description = "time is the timestamp when the error was encountered.";
                          format = "date-time";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    readyToUse = {
                      description = "readyToUse indicates if a snapshot is ready to be used to restore a volume. In dynamic snapshot creation case, this field will be filled in by the CSI snapshotter sidecar with the \"ready_to_use\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"ready_to_use\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it, otherwise, this field will be set to \"True\". If not specified, it means the readiness of a snapshot is unknown.";
                      type = "boolean";
                    };
                    restoreSize = {
                      description = "restoreSize represents the complete size of the snapshot in bytes. In dynamic snapshot creation case, this field will be filled in by the CSI snapshotter sidecar with the \"size_bytes\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"size_bytes\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it. When restoring a volume from this snapshot, the size of the volume MUST NOT be smaller than the restoreSize if it is specified, otherwise the restoration will fail. If not specified, it indicates that the size is unknown.";
                      format = "int64";
                      minimum = 0;
                      type = "integer";
                    };
                    snapshotHandle = {
                      description = "snapshotHandle is the CSI \"snapshot_id\" of a snapshot on the underlying storage system. If not specified, it indicates that dynamic snapshot creation has either failed or it is still in progress.";
                      type = "string";
                    };
                  };
                  type = "object";
                };
              };
              required = [
                "spec"
              ];
              type = "object";
            };
          };
          served = false;
          storage = false;
          subresources = {
            status = { };
          };
        }
      ];
    };
    status = {
      acceptedNames = {
        kind = "";
        plural = "";
      };
      conditions = [ ];
      storedVersions = [ ];
    };
  }
  {
    apiVersion = "apiextensions.k8s.io/v1";
    kind = "CustomResourceDefinition";
    metadata = {
      annotations = {
        "controller-gen.kubebuilder.io/version" = "v0.15.0";
        "api-approved.kubernetes.io" = "https://github.com/kubernetes-csi/external-snapshotter/pull/814";
      };
      name = "volumesnapshots.snapshot.storage.k8s.io";
    };
    spec = {
      group = "snapshot.storage.k8s.io";
      names = {
        kind = "VolumeSnapshot";
        listKind = "VolumeSnapshotList";
        plural = "volumesnapshots";
        shortNames = [
          "vs"
        ];
        singular = "volumesnapshot";
      };
      scope = "Namespaced";
      versions = [
        {
          additionalPrinterColumns = [
            {
              description = "Indicates if the snapshot is ready to be used to restore a volume.";
              jsonPath = ".status.readyToUse";
              name = "ReadyToUse";
              type = "boolean";
            }
            {
              description = "If a new snapshot needs to be created, this contains the name of the source PVC from which this snapshot was (or will be) created.";
              jsonPath = ".spec.source.persistentVolumeClaimName";
              name = "SourcePVC";
              type = "string";
            }
            {
              description = "If a snapshot already exists, this contains the name of the existing VolumeSnapshotContent object representing the existing snapshot.";
              jsonPath = ".spec.source.volumeSnapshotContentName";
              name = "SourceSnapshotContent";
              type = "string";
            }
            {
              description = "Represents the minimum size of volume required to rehydrate from this snapshot.";
              jsonPath = ".status.restoreSize";
              name = "RestoreSize";
              type = "string";
            }
            {
              description = "The name of the VolumeSnapshotClass requested by the VolumeSnapshot.";
              jsonPath = ".spec.volumeSnapshotClassName";
              name = "SnapshotClass";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshotContent object to which the VolumeSnapshot object intends to bind to. Please note that verification of binding actually requires checking both VolumeSnapshot and VolumeSnapshotContent to ensure both are pointing at each other. Binding MUST be verified prior to usage of this object.";
              jsonPath = ".status.boundVolumeSnapshotContentName";
              name = "SnapshotContent";
              type = "string";
            }
            {
              description = "Timestamp when the point-in-time snapshot was taken by the underlying storage system.";
              jsonPath = ".status.creationTime";
              name = "CreationTime";
              type = "date";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshot is a user's request for either creating a point-in-time\nsnapshot of a persistent volume, or binding to a pre-existing snapshot.";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                metadata = {
                  type = "object";
                };
                spec = {
                  description = "spec defines the desired characteristics of a snapshot requested by a user.\nMore info: https://kubernetes.io/docs/concepts/storage/volume-snapshots#volumesnapshots\nRequired.";
                  properties = {
                    source = {
                      description = "source specifies where a snapshot will be created from.\nThis field is immutable after creation.\nRequired.";
                      properties = {
                        persistentVolumeClaimName = {
                          description = "persistentVolumeClaimName specifies the name of the PersistentVolumeClaim\nobject representing the volume from which a snapshot should be created.\nThis PVC is assumed to be in the same namespace as the VolumeSnapshot\nobject.\nThis field should be set if the snapshot does not exists, and needs to be\ncreated.\nThis field is immutable.";
                          type = "string";
                          x-kubernetes-validations = [
                            {
                              message = "persistentVolumeClaimName is immutable";
                              rule = "self == oldSelf";
                            }
                          ];
                        };
                        volumeSnapshotContentName = {
                          description = "volumeSnapshotContentName specifies the name of a pre-existing VolumeSnapshotContent\nobject representing an existing volume snapshot.\nThis field should be set if the snapshot already exists and only needs a representation in Kubernetes.\nThis field is immutable.";
                          type = "string";
                          x-kubernetes-validations = [
                            {
                              message = "volumeSnapshotContentName is immutable";
                              rule = "self == oldSelf";
                            }
                          ];
                        };
                      };
                      type = "object";
                      x-kubernetes-validations = [
                        {
                          message = "persistentVolumeClaimName is required once set";
                          rule = "!has(oldSelf.persistentVolumeClaimName) || has(self.persistentVolumeClaimName)";
                        }
                        {
                          message = "volumeSnapshotContentName is required once set";
                          rule = "!has(oldSelf.volumeSnapshotContentName) || has(self.volumeSnapshotContentName)";
                        }
                        {
                          message = "exactly one of volumeSnapshotContentName and persistentVolumeClaimName must be set";
                          rule = "(has(self.volumeSnapshotContentName) && !has(self.persistentVolumeClaimName)) || (!has(self.volumeSnapshotContentName) && has(self.persistentVolumeClaimName))";
                        }
                      ];
                    };
                    volumeSnapshotClassName = {
                      description = "VolumeSnapshotClassName is the name of the VolumeSnapshotClass\nrequested by the VolumeSnapshot.\nVolumeSnapshotClassName may be left nil to indicate that the default\nSnapshotClass should be used.\nA given cluster may have multiple default Volume SnapshotClasses: one\ndefault per CSI Driver. If a VolumeSnapshot does not specify a SnapshotClass,\nVolumeSnapshotSource will be checked to figure out what the associated\nCSI Driver is, and the default VolumeSnapshotClass associated with that\nCSI Driver will be used. If more than one VolumeSnapshotClass exist for\na given CSI Driver and more than one have been marked as default,\nCreateSnapshot will fail and generate an event.\nEmpty string is not allowed for this field.";
                      type = "string";
                      x-kubernetes-validations = [
                        {
                          message = "volumeSnapshotClassName must not be the empty string when set";
                          rule = "size(self) > 0";
                        }
                      ];
                    };
                  };
                  required = [
                    "source"
                  ];
                  type = "object";
                };
                status = {
                  description = "status represents the current information of a snapshot.\nConsumers must verify binding between VolumeSnapshot and\nVolumeSnapshotContent objects is successful (by validating that both\nVolumeSnapshot and VolumeSnapshotContent point at each other) before\nusing this object.";
                  properties = {
                    boundVolumeSnapshotContentName = {
                      description = "boundVolumeSnapshotContentName is the name of the VolumeSnapshotContent\nobject to which this VolumeSnapshot object intends to bind to.\nIf not specified, it indicates that the VolumeSnapshot object has not been\nsuccessfully bound to a VolumeSnapshotContent object yet.\nNOTE: To avoid possible security issues, consumers must verify binding between\nVolumeSnapshot and VolumeSnapshotContent objects is successful (by validating that\nboth VolumeSnapshot and VolumeSnapshotContent point at each other) before using\nthis object.";
                      type = "string";
                    };
                    creationTime = {
                      description = "creationTime is the timestamp when the point-in-time snapshot is taken\nby the underlying storage system.\nIn dynamic snapshot creation case, this field will be filled in by the\nsnapshot controller with the \"creation_time\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"creation_time\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it.\nIf not specified, it may indicate that the creation time of the snapshot is unknown.";
                      format = "date-time";
                      type = "string";
                    };
                    error = {
                      description = "error is the last observed error during snapshot creation, if any.\nThis field could be helpful to upper level controllers(i.e., application controller)\nto decide whether they should continue on waiting for the snapshot to be created\nbased on the type of error reported.\nThe snapshot controller will keep retrying when an error occurs during the\nsnapshot creation. Upon success, this error field will be cleared.";
                      properties = {
                        message = {
                          description = "message is a string detailing the encountered error during snapshot\ncreation if specified.\nNOTE: message may be logged, and it should not contain sensitive\ninformation.";
                          type = "string";
                        };
                        time = {
                          description = "time is the timestamp when the error was encountered.";
                          format = "date-time";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    readyToUse = {
                      description = "readyToUse indicates if the snapshot is ready to be used to restore a volume.\nIn dynamic snapshot creation case, this field will be filled in by the\nsnapshot controller with the \"ready_to_use\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"ready_to_use\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it,\notherwise, this field will be set to \"True\".\nIf not specified, it means the readiness of a snapshot is unknown.";
                      type = "boolean";
                    };
                    restoreSize = {
                      type = "string";
                      description = "restoreSize represents the minimum size of volume required to create a volume\nfrom this snapshot.\nIn dynamic snapshot creation case, this field will be filled in by the\nsnapshot controller with the \"size_bytes\" value returned from CSI\n\"CreateSnapshot\" gRPC call.\nFor a pre-existing snapshot, this field will be filled with the \"size_bytes\"\nvalue returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it.\nWhen restoring a volume from this snapshot, the size of the volume MUST NOT\nbe smaller than the restoreSize if it is specified, otherwise the restoration will fail.\nIf not specified, it indicates that the size is unknown.";
                      pattern = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$";
                      x-kubernetes-int-or-string = true;
                    };
                    volumeGroupSnapshotName = {
                      description = "VolumeGroupSnapshotName is the name of the VolumeGroupSnapshot of which this\nVolumeSnapshot is a part of.";
                      type = "string";
                    };
                  };
                  type = "object";
                };
              };
              required = [
                "spec"
              ];
              type = "object";
            };
          };
          served = true;
          storage = true;
          subresources = {
            status = { };
          };
        }
        {
          additionalPrinterColumns = [
            {
              description = "Indicates if the snapshot is ready to be used to restore a volume.";
              jsonPath = ".status.readyToUse";
              name = "ReadyToUse";
              type = "boolean";
            }
            {
              description = "If a new snapshot needs to be created, this contains the name of the source PVC from which this snapshot was (or will be) created.";
              jsonPath = ".spec.source.persistentVolumeClaimName";
              name = "SourcePVC";
              type = "string";
            }
            {
              description = "If a snapshot already exists, this contains the name of the existing VolumeSnapshotContent object representing the existing snapshot.";
              jsonPath = ".spec.source.volumeSnapshotContentName";
              name = "SourceSnapshotContent";
              type = "string";
            }
            {
              description = "Represents the minimum size of volume required to rehydrate from this snapshot.";
              jsonPath = ".status.restoreSize";
              name = "RestoreSize";
              type = "string";
            }
            {
              description = "The name of the VolumeSnapshotClass requested by the VolumeSnapshot.";
              jsonPath = ".spec.volumeSnapshotClassName";
              name = "SnapshotClass";
              type = "string";
            }
            {
              description = "Name of the VolumeSnapshotContent object to which the VolumeSnapshot object intends to bind to. Please note that verification of binding actually requires checking both VolumeSnapshot and VolumeSnapshotContent to ensure both are pointing at each other. Binding MUST be verified prior to usage of this object.";
              jsonPath = ".status.boundVolumeSnapshotContentName";
              name = "SnapshotContent";
              type = "string";
            }
            {
              description = "Timestamp when the point-in-time snapshot was taken by the underlying storage system.";
              jsonPath = ".status.creationTime";
              name = "CreationTime";
              type = "date";
            }
            {
              jsonPath = ".metadata.creationTimestamp";
              name = "Age";
              type = "date";
            }
          ];
          name = "v1beta1";
          deprecated = true;
          deprecationWarning = "snapshot.storage.k8s.io/v1beta1 VolumeSnapshot is deprecated; use snapshot.storage.k8s.io/v1 VolumeSnapshot";
          schema = {
            openAPIV3Schema = {
              description = "VolumeSnapshot is a user's request for either creating a point-in-time snapshot of a persistent volume, or binding to a pre-existing snapshot.";
              properties = {
                apiVersion = {
                  description = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
                  type = "string";
                };
                kind = {
                  description = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
                  type = "string";
                };
                spec = {
                  description = "spec defines the desired characteristics of a snapshot requested by a user. More info: https://kubernetes.io/docs/concepts/storage/volume-snapshots#volumesnapshots Required.";
                  properties = {
                    source = {
                      description = "source specifies where a snapshot will be created from. This field is immutable after creation. Required.";
                      properties = {
                        persistentVolumeClaimName = {
                          description = "persistentVolumeClaimName specifies the name of the PersistentVolumeClaim object representing the volume from which a snapshot should be created. This PVC is assumed to be in the same namespace as the VolumeSnapshot object. This field should be set if the snapshot does not exists, and needs to be created. This field is immutable.";
                          type = "string";
                        };
                        volumeSnapshotContentName = {
                          description = "volumeSnapshotContentName specifies the name of a pre-existing VolumeSnapshotContent object representing an existing volume snapshot. This field should be set if the snapshot already exists and only needs a representation in Kubernetes. This field is immutable.";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    volumeSnapshotClassName = {
                      description = "VolumeSnapshotClassName is the name of the VolumeSnapshotClass requested by the VolumeSnapshot. VolumeSnapshotClassName may be left nil to indicate that the default SnapshotClass should be used. A given cluster may have multiple default Volume SnapshotClasses: one default per CSI Driver. If a VolumeSnapshot does not specify a SnapshotClass, VolumeSnapshotSource will be checked to figure out what the associated CSI Driver is, and the default VolumeSnapshotClass associated with that CSI Driver will be used. If more than one VolumeSnapshotClass exist for a given CSI Driver and more than one have been marked as default, CreateSnapshot will fail and generate an event. Empty string is not allowed for this field.";
                      type = "string";
                    };
                  };
                  required = [
                    "source"
                  ];
                  type = "object";
                };
                status = {
                  description = "status represents the current information of a snapshot. Consumers must verify binding between VolumeSnapshot and VolumeSnapshotContent objects is successful (by validating that both VolumeSnapshot and VolumeSnapshotContent point at each other) before using this object.";
                  properties = {
                    boundVolumeSnapshotContentName = {
                      description = "boundVolumeSnapshotContentName is the name of the VolumeSnapshotContent object to which this VolumeSnapshot object intends to bind to. If not specified, it indicates that the VolumeSnapshot object has not been successfully bound to a VolumeSnapshotContent object yet. NOTE: To avoid possible security issues, consumers must verify binding between VolumeSnapshot and VolumeSnapshotContent objects is successful (by validating that both VolumeSnapshot and VolumeSnapshotContent point at each other) before using this object.";
                      type = "string";
                    };
                    creationTime = {
                      description = "creationTime is the timestamp when the point-in-time snapshot is taken by the underlying storage system. In dynamic snapshot creation case, this field will be filled in by the snapshot controller with the \"creation_time\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"creation_time\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it. If not specified, it may indicate that the creation time of the snapshot is unknown.";
                      format = "date-time";
                      type = "string";
                    };
                    error = {
                      description = "error is the last observed error during snapshot creation, if any. This field could be helpful to upper level controllers(i.e., application controller) to decide whether they should continue on waiting for the snapshot to be created based on the type of error reported. The snapshot controller will keep retrying when an error occurs during the snapshot creation. Upon success, this error field will be cleared.";
                      properties = {
                        message = {
                          description = "message is a string detailing the encountered error during snapshot creation if specified. NOTE: message may be logged, and it should not contain sensitive information.";
                          type = "string";
                        };
                        time = {
                          description = "time is the timestamp when the error was encountered.";
                          format = "date-time";
                          type = "string";
                        };
                      };
                      type = "object";
                    };
                    readyToUse = {
                      description = "readyToUse indicates if the snapshot is ready to be used to restore a volume. In dynamic snapshot creation case, this field will be filled in by the snapshot controller with the \"ready_to_use\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"ready_to_use\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it, otherwise, this field will be set to \"True\". If not specified, it means the readiness of a snapshot is unknown.";
                      type = "boolean";
                    };
                    restoreSize = {
                      type = "string";
                      description = "restoreSize represents the minimum size of volume required to create a volume from this snapshot. In dynamic snapshot creation case, this field will be filled in by the snapshot controller with the \"size_bytes\" value returned from CSI \"CreateSnapshot\" gRPC call. For a pre-existing snapshot, this field will be filled with the \"size_bytes\" value returned from the CSI \"ListSnapshots\" gRPC call if the driver supports it. When restoring a volume from this snapshot, the size of the volume MUST NOT be smaller than the restoreSize if it is specified, otherwise the restoration will fail. If not specified, it indicates that the size is unknown.";
                      pattern = "^(\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\\+|-)?(([0-9]+(\\.[0-9]*)?)|(\\.[0-9]+))))?$";
                      x-kubernetes-int-or-string = true;
                    };
                  };
                  type = "object";
                };
              };
              required = [
                "spec"
              ];
              type = "object";
            };
          };
          served = false;
          storage = false;
          subresources = {
            status = { };
          };
        }
      ];
    };
    status = {
      acceptedNames = {
        kind = "";
        plural = "";
      };
      conditions = [ ];
      storedVersions = [ ];
    };
  }
  {
    kind = "Deployment";
    apiVersion = "apps/v1";
    metadata = {
      name = "snapshot-controller";
      namespace = "kube-system";
    };
    spec = {
      replicas = 2;
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "snapshot-controller";
        };
      };
      minReadySeconds = 35;
      strategy = {
        rollingUpdate = {
          maxSurge = 0;
          maxUnavailable = 1;
        };
        type = "RollingUpdate";
      };
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "snapshot-controller";
          };
        };
        spec = {
          serviceAccountName = "snapshot-controller";
          containers = [
            {
              name = "snapshot-controller";
              image = "registry.k8s.io/sig-storage/snapshot-controller:v8.5.0";
              args = [
                "--v=5"
                "--leader-election=true"
              ];
              imagePullPolicy = "IfNotPresent";
            }
          ];
        };
      };
    };
  }
  {
    apiVersion = "v1";
    kind = "PersistentVolumeClaim";
    metadata = {
      name = "reschedule-marker";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-reschedule-verification";
        "app.kubernetes.io/component" = "test";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      accessModes = [
        "ReadWriteOnce"
      ];
      storageClassName = "longhorn";
      resources = {
        requests = {
          storage = "1Gi";
        };
      };
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata = {
      name = "storage-reschedule-verification";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-reschedule-verification";
        "app.kubernetes.io/component" = "test";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      replicas = 1;
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "storage-reschedule-verification";
        };
      };
      template = {
        metadata = {
          labels = {
            "app.kubernetes.io/name" = "storage-reschedule-verification";
            "app.kubernetes.io/component" = "test";
            "app.kubernetes.io/part-of" = "storage";
          };
        };
        spec = {
          automountServiceAccountToken = false;
          securityContext = {
            runAsNonRoot = true;
            runAsUser = 65532;
            runAsGroup = 65532;
            fsGroup = 65532;
            seccompProfile = {
              type = "RuntimeDefault";
            };
          };
          containers = [
            {
              name = "marker";
              image = "docker.io/library/busybox:1.37.0@sha256:bdf57e528e45e4433820e045b29b4597825a1c9e38353532d90a01445013f82e";
              command = [
                "/bin/sh"
                "-ec"
              ];
              args = [
                "test -s /data/marker || printf 'initialized\\n' > /data/marker; exec sleep 86400"
              ];
              livenessProbe = {
                exec = {
                  command = [
                    "test"
                    "-s"
                    "/data/marker"
                  ];
                };
                periodSeconds = 10;
                initialDelaySeconds = 120;
              };
              readinessProbe = {
                exec = {
                  command = [
                    "test"
                    "-s"
                    "/data/marker"
                  ];
                };
                periodSeconds = 5;
              };
              resources = {
                requests = {
                  cpu = "5m";
                  memory = "8Mi";
                };
                limits = {
                  cpu = "100m";
                  memory = "32Mi";
                };
              };
              securityContext = {
                allowPrivilegeEscalation = false;
                capabilities = {
                  drop = [
                    "ALL"
                  ];
                };
                readOnlyRootFilesystem = true;
              };
              volumeMounts = [
                {
                  name = "data";
                  mountPath = "/data";
                }
              ];
            }
          ];
          volumes = [
            {
              name = "data";
              persistentVolumeClaim = {
                claimName = "reschedule-marker";
              };
            }
          ];
        };
      };
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "isolate-storage-reschedule-verification";
      namespace = "storage-verification";
      labels = {
        "app.kubernetes.io/name" = "storage-reschedule-verification";
        "app.kubernetes.io/component" = "policy";
        "app.kubernetes.io/part-of" = "storage";
      };
    };
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "storage-reschedule-verification";
        };
      };
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
      name = "allow-dns-egress";
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
              podSelector = {
                matchLabels = {
                  k8s-app = "kube-dns";
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
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "allow-intra-namespace";
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
        "Egress"
      ];
      ingress = [
        {
          from = [
            {
              podSelector = { };
            }
          ];
        }
      ];
      egress = [
        {
          to = [
            {
              podSelector = { };
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
      name = "deny-egress-by-default";
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Egress"
      ];
    };
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "deny-ingress-by-default";
    };
    spec = {
      podSelector = { };
      policyTypes = [
        "Ingress"
      ];
    };
  }
  {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "openbao-auth";
      namespace = "external-secrets";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authentication";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    automountServiceAccountToken = false;
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "Role";
    metadata = {
      name = "mint-openbao-auth-token";
      namespace = "external-secrets";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "serviceaccounts/token"
        ];
        resourceNames = [
          "openbao-auth"
        ];
        verbs = [
          "create"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";
    metadata = {
      name = "allow-external-secrets-to-mint-openbao-token";
      namespace = "external-secrets";
      labels = {
        "app.kubernetes.io/name" = "openbao-auth";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "Role";
      name = "mint-openbao-auth-token";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "external-secrets";
        namespace = "external-secrets";
      }
    ];
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ClusterSecretStore";
    metadata = {
      name = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao";
        "app.kubernetes.io/component" = "secret-store";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    spec = {
      conditions = [
        {
          namespaces = [
            "external-secrets"
          ];
        }
      ];
      provider = {
        vault = {
          server = "https://openbao-active.openbao.svc:8200";
          path = "secret";
          version = "v2";
          caProvider = {
            type = "Secret";
            namespace = "openbao";
            name = "openbao-server-tls";
            key = "ca.crt";
          };
          auth = {
            kubernetes = {
              mountPath = "kubernetes";
              role = "runtime-external-secrets";
              serviceAccountRef = {
                name = "openbao-auth";
                namespace = "external-secrets";
                audiences = [
                  "openbao"
                ];
              };
            };
          };
        };
      };
    };
  }
  {
    apiVersion = "v1";
    kind = "ServiceAccount";
    metadata = {
      name = "openbao-ca-reader";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "trust-distribution";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    automountServiceAccountToken = false;
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "Role";
    metadata = {
      name = "mint-openbao-ca-reader-token";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "serviceaccounts/token"
        ];
        resourceNames = [
          "openbao-ca-reader"
        ];
        verbs = [
          "create"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";
    metadata = {
      name = "allow-external-secrets-to-mint-openbao-ca-token";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "Role";
      name = "mint-openbao-ca-reader-token";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "external-secrets";
        namespace = "external-secrets";
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "Role";
    metadata = {
      name = "read-openbao-ca";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    rules = [
      {
        apiGroups = [
          ""
        ];
        resources = [
          "secrets"
        ];
        resourceNames = [
          "openbao-server-tls"
        ];
        verbs = [
          "get"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "RoleBinding";
    metadata = {
      name = "allow-openbao-ca-read";
      namespace = "openbao";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "Role";
      name = "read-openbao-ca";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "openbao-ca-reader";
        namespace = "openbao";
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "ClusterRole";
    metadata = {
      name = "review-openbao-ca-reader-permissions";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    rules = [
      {
        apiGroups = [
          "authorization.k8s.io"
        ];
        resources = [
          "selfsubjectrulesreviews"
        ];
        verbs = [
          "create"
        ];
      }
    ];
  }
  {
    apiVersion = "rbac.authorization.k8s.io/v1";
    kind = "ClusterRoleBinding";
    metadata = {
      name = "allow-openbao-ca-reader-review";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-reader";
        "app.kubernetes.io/component" = "authorization";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "ClusterRole";
      name = "review-openbao-ca-reader-permissions";
    };
    subjects = [
      {
        kind = "ServiceAccount";
        name = "openbao-ca-reader";
        namespace = "openbao";
      }
    ];
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ClusterSecretStore";
    metadata = {
      name = "openbao-ca-source";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca-source";
        "app.kubernetes.io/component" = "trust-distribution";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    spec = {
      provider = {
        kubernetes = {
          remoteNamespace = "openbao";
          server = {
            caProvider = {
              type = "ConfigMap";
              name = "kube-root-ca.crt";
              namespace = "openbao";
              key = "ca.crt";
            };
          };
          auth = {
            serviceAccount = {
              name = "openbao-ca-reader";
              namespace = "openbao";
            };
          };
        };
      };
    };
  }
  {
    apiVersion = "external-secrets.io/v1";
    kind = "ClusterExternalSecret";
    metadata = {
      name = "replicate-openbao-ca";
      labels = {
        "app.kubernetes.io/name" = "openbao-ca";
        "app.kubernetes.io/component" = "trust-distribution";
        "app.kubernetes.io/part-of" = "runtime-secrets";
      };
    };
    spec = {
      externalSecretName = "openbao-ca";
      namespaceSelectors = [
        {
          matchLabels = {
            "runtime-secrets.homelab.dev/openbao-ca" = "true";
          };
        }
      ];
      refreshTime = "1h";
      externalSecretMetadata = {
        labels = {
          "app.kubernetes.io/name" = "openbao-ca";
          "app.kubernetes.io/component" = "trust-distribution";
          "app.kubernetes.io/part-of" = "runtime-secrets";
        };
      };
      externalSecretSpec = {
        refreshInterval = "1h";
        secretStoreRef = {
          kind = "ClusterSecretStore";
          name = "openbao-ca-source";
        };
        target = {
          name = "openbao-ca";
          creationPolicy = "Owner";
          deletionPolicy = "Retain";
          template = {
            metadata = {
              labels = {
                "app.kubernetes.io/name" = "openbao-ca";
                "app.kubernetes.io/component" = "trust-distribution";
                "app.kubernetes.io/part-of" = "runtime-secrets";
              };
            };
          };
        };
        data = [
          {
            secretKey = "ca.crt";
            remoteRef = {
              key = "openbao-server-tls";
              property = "ca.crt";
            };
          }
        ];
      };
    };
  }
]
