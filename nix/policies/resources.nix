# One-time conversion from:
# - /home/anouar/kubernetes-homelab/policies/bootstrap/create-policy-namespaces.yaml
# - /home/anouar/kubernetes-homelab/policies/bootstrap/create-policy-namespaces.yaml
# - /home/anouar/kubernetes-homelab/policies/resources/restrict-policy-engine-network.yaml
# - /home/anouar/kubernetes-homelab/policies/resources/restrict-policy-engine-network.yaml
# - /home/anouar/kubernetes-homelab/policies/resources/show-security-posture.yaml
# - /home/anouar/kubernetes-homelab/policies/resources/show-security-posture.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-container-hardening.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-container-resources.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-health-probes.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-immutable-images.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-network-policy.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/require-workload-labels.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/restrict-image-registries.yaml
# - /home/anouar/kubernetes-homelab/policies/standards/audit/verify-signed-images.yaml
[
  {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "kyverno";
      labels = {
        "app.kubernetes.io/name" = "kyverno";
        "app.kubernetes.io/component" = "policy-engine";
        "app.kubernetes.io/part-of" = "homelab";
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
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "trivy-system";
      labels = {
        "app.kubernetes.io/name" = "trivy-operator";
        "app.kubernetes.io/component" = "vulnerability-scanner";
        "app.kubernetes.io/part-of" = "homelab";
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
      name = "restrict-kyverno";
      namespace = "kyverno";
      labels = {
        "app.kubernetes.io/name" = "kyverno-network-boundary";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "homelab-security";
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
          from = [
            {
              ipBlock = {
                cidr = "0.0.0.0/0";
              };
            }
          ];
          ports = [
            {
              protocol = "TCP";
              port = 9443;
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
              protocol = "TCP";
              port = 8000;
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
  }
  {
    apiVersion = "networking.k8s.io/v1";
    kind = "NetworkPolicy";
    metadata = {
      name = "restrict-trivy-operator";
      namespace = "trivy-system";
      labels = {
        "app.kubernetes.io/name" = "trivy-operator-network-boundary";
        "app.kubernetes.io/component" = "network-policy";
        "app.kubernetes.io/part-of" = "homelab-security";
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
  {
    apiVersion = "v1";
    kind = "ConfigMap";
    metadata = {
      name = "homelab-security-posture-dashboard";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "homelab-security-posture-dashboard";
        "app.kubernetes.io/component" = "dashboard";
        "app.kubernetes.io/part-of" = "homelab-security";
        grafana_dashboard = "1";
      };
    };
    data = {
      "security-posture.json" =
        "{\n  \"annotations\": {\"list\": []},\n  \"description\": \"Actionable image-vulnerability exposure reported by Trivy Operator. Unknown means the scanner is not providing data and is never treated as healthy.\",\n  \"editable\": false,\n  \"panels\": [\n    {\"collapsed\": false, \"gridPos\": {\"h\": 1, \"w\": 24, \"x\": 0, \"y\": 0}, \"id\": 1, \"panels\": [], \"title\": \"Exposure posture\", \"type\": \"row\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Critical vulnerabilities in images currently represented by Trivy metrics.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"red\", \"value\": 1}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 0, \"y\": 1}, \"id\": 2, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(trivy_image_vulnerabilities{severity=\\\"Critical\\\"})\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Critical findings\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"High-severity vulnerabilities in images currently represented by Trivy metrics.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 25}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 6, \"y\": 1}, \"id\": 3, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(trivy_image_vulnerabilities{severity=\\\"High\\\"})\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"High findings\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Namespaces containing at least one critical or high finding.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 5}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 12, \"y\": 1}, \"id\": 4, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"count(count by (namespace) (trivy_image_vulnerabilities{severity=~\\\"Critical|High\\\"} > 0))\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Affected namespaces\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"All critical and high vulnerabilities that should enter the remediation queue.\", \"fieldConfig\": {\"defaults\": {\"noValue\": \"Unknown\", \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 50}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 5, \"w\": 6, \"x\": 18, \"y\": 1}, \"id\": 5, \"options\": {\"colorMode\": \"background\", \"graphMode\": \"area\", \"justifyMode\": \"auto\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"textMode\": \"auto\"}, \"targets\": [{\"expr\": \"sum(trivy_image_vulnerabilities{severity=~\\\"Critical|High\\\"})\", \"instant\": true, \"refId\": \"A\"}], \"title\": \"Actionable findings\", \"type\": \"stat\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Critical and high findings ranked by namespace so remediation starts where exposure is concentrated.\", \"fieldConfig\": {\"defaults\": {\"min\": 0, \"thresholds\": {\"mode\": \"absolute\", \"steps\": [{\"color\": \"green\", \"value\": null}, {\"color\": \"orange\", \"value\": 1}, {\"color\": \"red\", \"value\": 25}]}, \"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 9, \"w\": 14, \"x\": 0, \"y\": 6}, \"id\": 6, \"options\": {\"displayMode\": \"gradient\", \"legend\": {\"calcs\": [], \"displayMode\": \"list\", \"placement\": \"bottom\"}, \"maxVizHeight\": 300, \"minVizHeight\": 16, \"minVizWidth\": 8, \"namePlacement\": \"auto\", \"orientation\": \"horizontal\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"showUnfilled\": true, \"sizing\": \"auto\", \"valueMode\": \"color\"}, \"targets\": [{\"expr\": \"sum by (namespace, severity) (trivy_image_vulnerabilities{severity=~\\\"Critical|High\\\"})\", \"instant\": true, \"legendFormat\": \"{{namespace}} / {{severity}}\", \"refId\": \"A\"}], \"title\": \"Exposure by namespace\", \"type\": \"bargauge\"},\n    {\"datasource\": {\"type\": \"prometheus\", \"uid\": \"prometheus\"}, \"description\": \"Finding distribution by severity. Critical and high drive the immediate remediation queue; lower severities remain visible for planning.\", \"fieldConfig\": {\"defaults\": {\"unit\": \"short\"}, \"overrides\": []}, \"gridPos\": {\"h\": 9, \"w\": 10, \"x\": 14, \"y\": 6}, \"id\": 7, \"options\": {\"displayLabels\": [\"name\", \"value\"], \"legend\": {\"displayMode\": \"table\", \"placement\": \"right\", \"showLegend\": true, \"values\": [\"value\"]}, \"pieType\": \"donut\", \"reduceOptions\": {\"calcs\": [\"lastNotNull\"], \"fields\": \"\", \"values\": false}, \"tooltip\": {\"hideZeros\": false, \"mode\": \"single\", \"sort\": \"none\"}}, \"targets\": [{\"expr\": \"sum by (severity) (trivy_image_vulnerabilities)\", \"instant\": true, \"legendFormat\": \"{{severity}}\", \"refId\": \"A\"}], \"title\": \"Findings by severity\", \"type\": \"piechart\"}\n  ],\n  \"refresh\": \"5m\", \"schemaVersion\": 42, \"tags\": [\"homelab\", \"security\", \"trivy\", \"drilldown\"], \"templating\": {\"list\": []}, \"time\": {\"from\": \"now-24h\", \"to\": \"now\"}, \"timepicker\": {\"refresh_intervals\": [\"1m\", \"5m\", \"15m\"], \"time_options\": [\"6h\", \"24h\", \"2d\", \"7d\"]}, \"timezone\": \"browser\", \"title\": \"Homelab / Security posture\", \"uid\": \"homelab-security-posture\", \"version\": 2\n}";
    };
  }
  {
    apiVersion = "monitoring.coreos.com/v1";
    kind = "PrometheusRule";
    metadata = {
      name = "homelab-security-findings";
      namespace = "monitoring";
      labels = {
        "app.kubernetes.io/name" = "homelab-security-findings";
        "app.kubernetes.io/component" = "alerting";
        "app.kubernetes.io/part-of" = "homelab-security";
        release = "monitoring";
      };
    };
    spec = {
      groups = [
        {
          name = "homelab.security";
          rules = [
            {
              alert = "CriticalContainerVulnerabilityDetected";
              expr = "sum(trivy_image_vulnerabilities{severity=\"Critical\"}) > 0";
              for = "15m";
              labels = {
                severity = "critical";
              };
              annotations = {
                summary = "Trivy reports a critical container-image vulnerability";
                description = "Review the Trivy report and rebuild or replace the affected image.";
                runbook_url = "https://github.com/\${CONFIG_GITHUB_PROJECT_PATH}/blob/main/docs/runbooks/respond-to-security-findings.md#critical-container-vulnerability-detected";
              };
            }
          ];
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "require-container-hardening";
      annotations = {
        "policies.kyverno.io/title" = "Require restricted container security";
        "policies.kyverno.io/category" = "Homelab workload baseline";
        "policies.kyverno.io/severity" = "high";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/profile" = "application";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      variables = [
        {
          name = "allContainers";
          expression = "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])";
        }
      ];
      validations = [
        {
          expression = "object.spec.?securityContext.?runAsNonRoot.orValue(false) || variables.allContainers.all(container, container.?securityContext.?runAsNonRoot.orValue(false))";
          message = "Pods or every container must set runAsNonRoot to true.";
        }
        {
          expression = "variables.allContainers.all(container, container.?securityContext.?allowPrivilegeEscalation.orValue(true) == false && container.?securityContext.?privileged.orValue(false) == false && container.?securityContext.?readOnlyRootFilesystem.orValue(false) == true && container.?securityContext.?capabilities.?drop.orValue([]).exists(capability, capability.upperAscii() == 'ALL'))";
          message = "Containers must deny privilege escalation, avoid privileged mode, use a read-only root filesystem, and drop ALL capabilities.";
        }
        {
          expression = "object.spec.?securityContext.?seccompProfile.?type.orValue('') in ['RuntimeDefault', 'Localhost'] || variables.allContainers.all(container, container.?securityContext.?seccompProfile.?type.orValue('') in ['RuntimeDefault', 'Localhost'])";
          message = "Pods or every container must set seccomp to RuntimeDefault or Localhost.";
        }
        {
          expression = "object.spec.?volumes.orValue([]).all(volume, !has(volume.hostPath))";
          message = "Application Pods may not use hostPath volumes.";
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "require-container-resources";
      annotations = {
        "policies.kyverno.io/title" = "Require container requests and limits";
        "policies.kyverno.io/category" = "Homelab workload baseline";
        "policies.kyverno.io/severity" = "medium";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/profile" = "application";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      variables = [
        {
          name = "allContainers";
          expression = "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])";
        }
      ];
      validations = [
        {
          expression = "variables.allContainers.all(container, has(container.resources) && has(container.resources.requests) && has(container.resources.requests.cpu) && container.resources.requests.cpu != '' && has(container.resources.requests.memory) && container.resources.requests.memory != '' && has(container.resources.limits) && has(container.resources.limits.cpu) && container.resources.limits.cpu != '' && has(container.resources.limits.memory) && container.resources.limits.memory != '')";
          message = "Every container requires CPU and memory requests and limits.";
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "require-health-probes";
      annotations = {
        "policies.kyverno.io/title" = "Require liveness and readiness probes";
        "policies.kyverno.io/category" = "Homelab workload baseline";
        "policies.kyverno.io/severity" = "medium";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/profile" = "application";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      validations = [
        {
          expression = "object.spec.containers.all(container, has(container.livenessProbe) && has(container.readinessProbe))";
          message = "Every application container requires liveness and readiness probes.";
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "require-immutable-images";
      annotations = {
        "policies.kyverno.io/title" = "Require digest-pinned images";
        "policies.kyverno.io/category" = "Software supply chain";
        "policies.kyverno.io/severity" = "high";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/profile" = "application";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      variables = [
        {
          name = "allContainers";
          expression = "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])";
        }
      ];
      validations = [
        {
          expression = "variables.allContainers.all(container, container.image.contains('@sha256:') && !container.image.endsWith(':latest'))";
          message = "Images must use a sha256 digest and may not use the latest tag.";
        }
      ];
    };
  }
  {
    apiVersion = "kyverno.io/v1";
    kind = "ClusterPolicy";
    metadata = {
      name = "require-network-policy";
      annotations = {
        "policies.kyverno.io/title" = "Require a matching NetworkPolicy";
        "policies.kyverno.io/category" = "Network isolation";
        "policies.kyverno.io/severity" = "high";
        "policies.kyverno.io/minversion" = "1.6.0";
      };
    };
    spec = {
      # Kyverno calls its deny-on-violation mode "Enforce"; the native
      # Kubernetes ValidatingPolicy objects above correctly use "Deny".
      validationFailureAction = "Enforce";
      background = false;
      rules = [
        {
          name = "require-network-policy";
          match = {
            any = [
              {
                resources = {
                  kinds = [
                    "Deployment"
                    "StatefulSet"
                    "DaemonSet"
                  ];
                  namespaces = [
                    "apps-*"
                  ];
                };
              }
            ];
          };
          preconditions = {
            all = [
              {
                key = "{{ request.operation }}";
                operator = "AnyIn";
                value = [
                  "CREATE"
                  "UPDATE"
                ];
              }
            ];
          };
          context = [
            {
              name = "matchingPolicies";
              apiCall = {
                urlPath = "/apis/networking.k8s.io/v1/namespaces/{{ request.namespace }}/networkpolicies";
                jmesPath = "items[?label_match(spec.podSelector.matchLabels, `{{ request.object.spec.template.metadata.labels }}`)] | length(@)";
              };
            }
          ];
          validate = {
            message = "Every application workload requires a matching NetworkPolicy.";
            deny = {
              conditions = {
                all = [
                  {
                    key = "{{ matchingPolicies }}";
                    operator = "LessThan";
                    value = 1;
                  }
                ];
              };
            };
          };
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "require-workload-labels";
      annotations = {
        "policies.kyverno.io/title" = "Require workload identity labels";
        "policies.kyverno.io/category" = "Homelab workload baseline";
        "policies.kyverno.io/severity" = "medium";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/profile" = "application";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      validations = [
        {
          expression = "has(object.metadata.labels) && ['app.kubernetes.io/name', 'app.kubernetes.io/component', 'app.kubernetes.io/part-of'].all(label, label in object.metadata.labels && object.metadata.labels[label] != '')";
          message = "Pods require non-empty app.kubernetes.io/name, component, and part-of labels.";
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ValidatingPolicy";
    metadata = {
      name = "restrict-image-registries";
      annotations = {
        "policies.kyverno.io/title" = "Restrict signed application registries";
        "policies.kyverno.io/category" = "Software supply chain";
        "policies.kyverno.io/severity" = "high";
      };
    };
    spec = {
      failurePolicy = "Fail";
      evaluation = {
        background = {
          enabled = true;
        };
      };
      validationActions = [
        "Deny"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/supply-chain" = "signed";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      variables = [
        {
          name = "allContainers";
          expression = "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])";
        }
      ];
      validations = [
        {
          expression = "variables.allContainers.all(container, container.image.startsWith('\${CONFIG_GHCR_REGISTRY_PATH}/'))";
          message = "Signed application namespaces may pull only from the configured GitLab registry.";
        }
      ];
    };
  }
  {
    apiVersion = "policies.kyverno.io/v1";
    kind = "ImageValidatingPolicy";
    metadata = {
      name = "verify-signed-images";
      annotations = {
        "policies.kyverno.io/title" = "Verify GitHub Actions keyless image signatures";
        "policies.kyverno.io/category" = "Software supply chain";
        "policies.kyverno.io/severity" = "high";
      };
    };
    spec = {
      failurePolicy = "Fail";
      webhookConfiguration = {
        timeoutSeconds = 30;
      };
      evaluation = {
        background = {
          enabled = false;
        };
      };
      validationActions = [
        # Promotion to Deny is gated on the first workflow-published, keyless-
        # signed release. Keeping this one policy in Audit avoids making the
        # currently referenced migration images unschedulable.
        "Audit"
      ];
      matchConstraints = {
        namespaceSelector = {
          matchLabels = {
            "policy.homelab.dev/supply-chain" = "signed";
          };
        };
        resourceRules = [
          {
            apiGroups = [
              ""
            ];
            apiVersions = [
              "v1"
            ];
            operations = [
              "CREATE"
              "UPDATE"
            ];
            resources = [
              "pods"
            ];
          }
        ];
      };
      matchImageReferences = [
        {
          glob = "\${CONFIG_GHCR_REGISTRY_PATH}/homelab-sentinel-*";
        }
      ];
      attestors = [
        {
          name = "github-main";
          cosign = {
            keyless = {
              identities = [
                {
                  subject = "\${CONFIG_GITHUB_CI_IDENTITY}";
                  issuer = "https://token.actions.githubusercontent.com";
                }
              ];
            };
            ctlog = {
              url = "https://rekor.sigstore.dev";
            };
          };
        }
      ];
      validations = [
        {
          expression = "images.containers.map(image, verifyImageSignatures(image, [attestors.github-main])).all(result, result > 0)";
          message = "The image must have a valid GitHub Actions main-branch keyless signature.";
        }
      ];
    };
  }
]
