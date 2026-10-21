# Generated once from /home/anouar/kubernetes-homelab/policies/tests/values.yaml
[
  {
    apiVersion = "cli.kyverno.io/v1alpha1";
    kind = "Values";
    metadata = {
      name = "application-workload-baseline";
    };
    namespaceSelector = [
      {
        name = "apps-valid";
        labels = {
          "policy.homelab.dev/profile" = "application";
        };
      }
      {
        name = "apps-invalid";
        labels = {
          "policy.homelab.dev/profile" = "application";
        };
      }
    ];
  }
]
