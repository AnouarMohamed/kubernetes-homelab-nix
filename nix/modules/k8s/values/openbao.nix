# Generated once from /home/anouar/kubernetes-homelab/platform/openbao/configure-openbao.yaml
[
  {
    global = {
      tlsDisable = false;
    };
    injector = {
      enabled = false;
    };
    server = {
      authDelegator = {
        enabled = true;
      };
      image = {
        registry = "quay.io";
        repository = "openbao/openbao";
        tag = "2.7.1@sha256:6d2b93856e3fcf7b18ad855a0b51eaba474dc8b79cf554379ea32034797d2acf";
        pullPolicy = "IfNotPresent";
      };
      updateStrategyType = "OnDelete";
      logLevel = "info";
      logFormat = "json";
      resources = {
        requests = {
          cpu = "100m";
          memory = "256Mi";
        };
        limits = {
          cpu = "1";
          memory = "1Gi";
        };
      };
      readinessProbe = {
        enabled = true;
        initialDelaySeconds = 10;
        periodSeconds = 5;
        timeoutSeconds = 3;
        failureThreshold = 3;
      };
      livenessProbe = {
        enabled = true;
        path = "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204";
        initialDelaySeconds = 60;
        periodSeconds = 10;
        timeoutSeconds = 3;
        failureThreshold = 3;
      };
      dataStorage = {
        enabled = true;
        size = "10Gi";
        storageClass = "longhorn";
        accessMode = "ReadWriteOnce";
      };
      auditStorage = {
        enabled = true;
        size = "5Gi";
        storageClass = "longhorn";
        accessMode = "ReadWriteOnce";
      };
      persistentVolumeClaimRetentionPolicy = {
        whenDeleted = "Retain";
        whenScaled = "Retain";
      };
      volumes = [
        {
          name = "tmp";
          emptyDir = {
            sizeLimit = "64Mi";
          };
        }
        {
          name = "tls";
          secret = {
            secretName = "openbao-server-tls";
          };
        }
        {
          name = "configuration";
          configMap = {
            name = "openbao-runtime-configuration";
            defaultMode = 360;
          };
        }
      ];
      volumeMounts = [
        {
          name = "tmp";
          mountPath = "/tmp";
        }
        {
          name = "tls";
          mountPath = "/openbao/tls";
          readOnly = true;
        }
        {
          name = "configuration";
          mountPath = "/openbao/configuration";
          readOnly = true;
        }
      ];
      statefulSet = {
        securityContext = {
          pod = {
            runAsNonRoot = true;
            runAsUser = 100;
            runAsGroup = 1000;
            fsGroup = 1000;
            seccompProfile = {
              type = "RuntimeDefault";
            };
          };
          container = {
            allowPrivilegeEscalation = false;
            capabilities = {
              drop = [
                "ALL"
              ];
            };
            readOnlyRootFilesystem = true;
          };
        };
      };
      networkPolicy = {
        enabled = true;
        ingress = [
          {
            from = [
              {
                podSelector = { };
              }
            ];
            ports = [
              {
                protocol = "TCP";
                port = 8200;
              }
              {
                protocol = "TCP";
                port = 8201;
              }
            ];
          }
          {
            from = [
              {
                namespaceSelector = {
                  matchLabels = {
                    "kubernetes.io/metadata.name" = "external-secrets";
                  };
                };
              }
              {
                namespaceSelector = {
                  matchLabels = {
                    "kubernetes.io/metadata.name" = "monitoring";
                  };
                };
              }
              {
                namespaceSelector = {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/metadata.name";
                      operator = "In";
                      values = [
                        "apps-sentinel"
                        "apps-sentinel-staging"
                        "apps-vaultwarden"
                        "keycloak"
                      ];
                    }
                  ];
                };
              }
            ];
            ports = [
              {
                protocol = "TCP";
                port = 8200;
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
      standalone = {
        enabled = false;
      };
      ha = {
        enabled = true;
        replicas = 3;
        raft = {
          enabled = true;
          setNodeId = true;
          config = "ui = true\n\nlistener \"tcp\" {\n  address = \"[::]:8200\"\n  cluster_address = \"[::]:8201\"\n  tls_cert_file = \"/openbao/tls/tls.crt\"\n  tls_key_file = \"/openbao/tls/tls.key\"\n  tls_client_ca_file = \"/openbao/tls/ca.crt\"\n  telemetry {\n    unauthenticated_metrics_access = \"true\"\n  }\n}\n\nstorage \"raft\" {\n  path = \"/openbao/data\"\n  retry_join {\n    leader_api_addr = \"https://openbao-0.openbao-internal:8200\"\n    leader_tls_servername = \"openbao.openbao.svc\"\n    leader_ca_cert_file = \"/openbao/tls/ca.crt\"\n  }\n  retry_join {\n    leader_api_addr = \"https://openbao-1.openbao-internal:8200\"\n    leader_tls_servername = \"openbao.openbao.svc\"\n    leader_ca_cert_file = \"/openbao/tls/ca.crt\"\n  }\n  retry_join {\n    leader_api_addr = \"https://openbao-2.openbao-internal:8200\"\n    leader_tls_servername = \"openbao.openbao.svc\"\n    leader_ca_cert_file = \"/openbao/tls/ca.crt\"\n  }\n}\n\naudit \"file\" \"file\" {\n  description = \"Persistent JSON audit log\"\n  options = {\n    file_path = \"/openbao/audit/audit.log\"\n    log_raw = \"false\"\n    mode = \"0600\"\n  }\n}\n\nservice_registration \"kubernetes\" {}\n\ntelemetry {\n  prometheus_retention_time = \"30s\"\n  disable_hostname = true\n}\n";
        };
        disruptionBudget = {
          enabled = true;
          maxUnavailable = 1;
        };
      };
    };
    ui = {
      enabled = true;
      serviceType = "ClusterIP";
      activeOpenbaoPodOnly = true;
    };
    serverTelemetry = {
      prometheusOperator = false;
    };
  }
]
