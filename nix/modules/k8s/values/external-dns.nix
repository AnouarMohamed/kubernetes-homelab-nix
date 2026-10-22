# Generated once from /home/anouar/kubernetes-homelab/platform/external-dns/configure-external-dns.yaml
[
  {
    image.tag = "v0.22.0@sha256:5fdcaf7deb5c158f93a1fc6fe169cdff4cfb9ae0172bee1a90ab0ef74fb9c9cf";
    replicaCount = 1;
    provider = {
      name = "cloudflare";
    };
    env = [
      {
        name = "CF_API_TOKEN";
        valueFrom = {
          secretKeyRef = {
            name = "cloudflare-api-token";
            key = "api-token";
          };
        };
      }
    ];
    sources = [
      "gateway-httproute"
    ];
    policy = "upsert-only";
    registry = "txt";
    txtOwnerId = "homelab-external-dns";
    domainFilters = [
      "\${CONFIG_DOMAIN}"
    ];
    annotationFilter = "external-dns.kubernetes.io/managed-by=homelab";
    extraArgs = {
      cloudflare-proxied = true;
      events = true;
      gateway-name = "public";
      gateway-namespace = "gateways";
    };
    resources = {
      requests = {
        cpu = "20m";
        memory = "64Mi";
      };
      limits = {
        cpu = "300m";
        memory = "192Mi";
      };
    };
    serviceMonitor = {
      enabled = false;
    };
  }
]
