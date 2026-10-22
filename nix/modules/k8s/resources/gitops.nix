{ homelab }:
[
  {
    apiVersion = "argoproj.io/v1alpha1";
    kind = "AppProject";
    metadata = {
      name = "homelab-rendered";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "homelab-rendered";
        "app.kubernetes.io/part-of" = "argocd";
      };
    };
    spec = {
      description = "Reconcile only the Nix-rendered production artifact from the canonical repository.";
      sourceRepos = [ homelab.repository ];
      destinations = [
        {
          namespace = "*";
          server = "https://kubernetes.default.svc";
        }
      ];
      # The rendered artifact owns cluster-scoped CRDs, RBAC, storage classes,
      # admission policies, and namespaced workloads. The broad kind allowance
      # is bounded by the single trusted source repository above and protected
      # by CI schema, policy, image, and identity checks before merge.
      clusterResourceWhitelist = [
        {
          group = "*";
          kind = "*";
        }
      ];
      orphanedResources.warn = true;
    };
  }
  {
    apiVersion = "argoproj.io/v1alpha1";
    kind = "Application";
    metadata = {
      name = "homelab-rendered";
      namespace = "argocd";
      labels = {
        "app.kubernetes.io/name" = "homelab-rendered";
        "app.kubernetes.io/part-of" = "argocd";
      };
      annotations."argocd.argoproj.io/sync-wave" = "100";
    };
    spec = {
      project = "homelab-rendered";
      source = {
        repoURL = homelab.repository;
        targetRevision = "main";
        path = "rendered";
        directory.recurse = false;
      };
      destination = {
        server = "https://kubernetes.default.svc";
        namespace = "argocd";
      };
      syncPolicy = {
        automated = {
          prune = true;
          selfHeal = true;
          allowEmpty = false;
        };
        retry = {
          limit = 5;
          backoff = {
            duration = "10s";
            factor = 2;
            maxDuration = "5m";
          };
        };
        syncOptions = [
          "ApplyOutOfSyncOnly=true"
          "PruneLast=true"
          "ServerSideApply=true"
        ];
      };
    };
  }
]
