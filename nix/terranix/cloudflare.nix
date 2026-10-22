{
  config,
  lib,
  ...
}:
{
  terraform.required_providers.cloudflare = {
    source = "cloudflare/cloudflare";
    version = "5.27.0";
  };
  variable = {
    cloudflare_account_id = {
      type = "string";
      sensitive = true;
    };
    cloudflare_zone_id = {
      type = "string";
      sensitive = true;
    };
    public_domain.type = "string";
    private_route_cidr.type = "string";
  };
  resource = {
    cloudflare_zero_trust_tunnel_cloudflared.homelab = {
      account_id = config.variable.cloudflare_account_id;
      name = "homelab";
      config_src = "cloudflare";
    };
    cloudflare_zero_trust_tunnel_cloudflared_config.homelab = {
      account_id = config.variable.cloudflare_account_id;
      tunnel_id = config.resource.cloudflare_zero_trust_tunnel_cloudflared.homelab "id";
      config.ingress = [
        {
          hostname = "whoami.\${var.public_domain}";
          service = "http://cilium-gateway-public.gateways.svc.cluster.local:80";
        }
        {
          hostname = "status.\${var.public_domain}";
          service = "http://cilium-gateway-public.gateways.svc.cluster.local:80";
        }
        { service = "http_status:404"; }
      ];
    };
    cloudflare_zero_trust_tunnel_cloudflared_route.homelab_admin = {
      account_id = config.variable.cloudflare_account_id;
      tunnel_id = config.resource.cloudflare_zero_trust_tunnel_cloudflared.homelab "id";
      network = config.variable.private_route_cidr;
      comment = "Homelab administration through WARP";
    };
    cloudflare_dns_record = lib.genAttrs [ "whoami" "status" ] (name: {
      zone_id = config.variable.cloudflare_zone_id;
      name = "${name}.\${var.public_domain}";
      type = "CNAME";
      content = "\${cloudflare_zero_trust_tunnel_cloudflared.homelab.id}.cfargotunnel.com";
      proxied = true;
      ttl = 1;
    });
  };
}
