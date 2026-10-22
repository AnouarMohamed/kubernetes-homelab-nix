# Generated once from /home/anouar/kubernetes-homelab/platform/argocd/configure-argocd.yaml
[
  {
    global = {
      domain = "argocd.\${CONFIG_DOMAIN}";
      image = {
        repository = "quay.io/argoproj/argocd";
        tag = "v3.5.4@sha256:49dff79439bb38b1b942b19a113fe1fec7e6b6c671ddf9fe6a4a7c46bde0b77b";
        imagePullPolicy = "IfNotPresent";
      };
      logging = {
        format = "json";
        level = "info";
      };
      networkPolicy = {
        create = true;
        defaultDenyIngress = true;
      };
      securityContext = {
        runAsNonRoot = true;
        runAsUser = 999;
        runAsGroup = 999;
        fsGroup = 999;
        seccompProfile = {
          type = "RuntimeDefault";
        };
      };
    };
    configs = {
      cm = {
        "admin.enabled" = true;
        "accounts.platform-reader" = "login";
        "exec.enabled" = false;
        "resource.customizations.health.argoproj.io_Application" =
          "hs = {}\nhs.status = \"Progressing\"\nhs.message = \"Waiting for child application health\"\nif obj.status ~= nil and obj.status.health ~= nil then\n  hs.status = obj.status.health.status\n  if obj.status.health.message ~= nil then\n    hs.message = obj.status.health.message\n  end\nend\nreturn hs\n";
        "statusbadge.enabled" = false;
        "timeout.reconciliation" = "180s";
        "oidc.config" =
          "name: Keycloak\nissuer: https://keycloak.\${CONFIG_DOMAIN}/realms/homelab\nclientID: argocd\nclientSecret: $argocd-oidc:client-secret\nrequestedScopes:\n  - openid\n  - profile\n  - email\n  - groups\n";
      };
      params = {
        "applicationsetcontroller.enable.scm.providers" = "false";
        "server.insecure" = false;
      };
      rbac = {
        "policy.default" = "role:readonly";
        "policy.csv" =
          "g, platform-reader, role:readonly\ng, homelab-viewers, role:readonly\ng, homelab-admins, role:admin\n";
        scopes = "[groups]";
      };
      # Argo CD consumes the committed Nix artifact directly. Rendering and
      # secret decryption never run in the cluster or in the repo-server trust
      # boundary.
      cmp = {
        create = false;
        plugins = { };
      };
    };
    controller = {
      replicas = 1;
      resources = {
        requests = {
          cpu = "200m";
          memory = "768Mi";
        };
        limits = {
          cpu = 1;
          memory = "2Gi";
        };
      };
      metrics = {
        enabled = true;
      };
    };
    applicationSet = {
      replicas = 2;
      pdb = {
        enabled = true;
        maxUnavailable = 1;
        unhealthyPodEvictionPolicy = "AlwaysAllow";
      };
      resources = {
        requests = {
          cpu = "50m";
          memory = "128Mi";
        };
        limits = {
          cpu = "500m";
          memory = "512Mi";
        };
      };
      metrics = {
        enabled = true;
      };
    };
    dex = {
      enabled = false;
    };
    notifications = {
      enabled = true;
      image = {
        repository = "quay.io/argoproj/argocd";
        tag = "v3.5.4@sha256:49dff79439bb38b1b942b19a113fe1fec7e6b6c671ddf9fe6a4a7c46bde0b77b";
        imagePullPolicy = "IfNotPresent";
      };
      secret = {
        create = false;
        name = "argocd-notifications-secret";
      };
      metrics = {
        enabled = true;
      };
      resources = {
        requests = {
          cpu = "25m";
          memory = "64Mi";
        };
        limits = {
          cpu = "250m";
          memory = "256Mi";
        };
      };
      readinessProbe = {
        enabled = true;
      };
      livenessProbe = {
        enabled = true;
      };
      notifiers = {
        "service.webhook.platform" =
          "url: $webhook-url\nheaders:\n  - name: Content-Type\n    value: application/json";
      };
      templates = {
        "template.platform-sync-status" =
          "webhook:\n  platform:\n    method: POST\n    body: |\n      {\"application\":\"{{.app.metadata.name}}\",\"sync\":\"{{.app.status.sync.status}}\",\"health\":\"{{.app.status.health.status}}\"}";
      };
      triggers = {
        "trigger.on-platform-degraded" =
          "- description: Application health is degraded.\n  send:\n    - platform-sync-status\n  when: app.status.health.status == 'Degraded'";
        "trigger.on-platform-out-of-sync" =
          "- description: Application remains out of sync.\n  send:\n    - platform-sync-status\n  when: app.status.sync.status == 'OutOfSync'";
      };
      subscriptions = [
        {
          recipients = [
            "platform"
          ];
          triggers = [
            "on-platform-degraded"
            "on-platform-out-of-sync"
          ];
        }
      ];
    };
    server = {
      replicas = 2;
      pdb = {
        enabled = true;
        maxUnavailable = 1;
        unhealthyPodEvictionPolicy = "AlwaysAllow";
      };
      resources = {
        requests = {
          cpu = "100m";
          memory = "128Mi";
        };
        limits = {
          cpu = "500m";
          memory = "512Mi";
        };
      };
      metrics = {
        enabled = true;
      };
      service = {
        type = "ClusterIP";
      };
      ingress = {
        enabled = false;
      };
      ingressGrpc = {
        enabled = false;
      };
      httproute = {
        enabled = false;
      };
      grpcroute = {
        enabled = false;
      };
    };
    repoServer = {
      replicas = 2;
      automountServiceAccountToken = false;
      serviceAccount = {
        automountServiceAccountToken = false;
      };
      pdb = {
        enabled = true;
        maxUnavailable = 1;
        unhealthyPodEvictionPolicy = "AlwaysAllow";
      };
      resources = {
        requests = {
          cpu = "100m";
          memory = "256Mi";
        };
        limits = {
          cpu = 1;
          memory = "1Gi";
        };
      };
      metrics = {
        enabled = true;
      };
      # The committed rendered artifact needs no in-cluster renderer, custom binaries,
      # or decryption key mount.
      initContainers = [ ];
      extraContainers = [ ];
      volumes = [ ];
    };
    redis = {
      enabled = true;
      image.tag = "8.6.4-alpine@sha256:2cc044fc5a07c9b701f8f1255a309ae9ad7856e694ac03513bf3648c01e40763";
      automountServiceAccountToken = false;
      readinessProbe = {
        enabled = true;
      };
      livenessProbe = {
        enabled = true;
      };
      resources = {
        requests = {
          cpu = "50m";
          memory = "64Mi";
        };
        limits = {
          cpu = "250m";
          memory = "256Mi";
        };
      };
      pdb = {
        enabled = true;
        maxUnavailable = 1;
        unhealthyPodEvictionPolicy = "AlwaysAllow";
      };
    };
    redisSecretInit = {
      enabled = true;
      resources = {
        requests = {
          cpu = "10m";
          memory = "32Mi";
        };
        limits = {
          cpu = "100m";
          memory = "128Mi";
        };
      };
    };
    test = {
      enabled = false;
    };
  }
]
