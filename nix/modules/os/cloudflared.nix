{ config, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels."00000000-0000-0000-0000-000000000000" = {
      credentialsFile = config.sops.secrets.cloudflare-tunnel-credentials.path;
      default = "http_status:404";
      warp-routing.enabled = true;
    };
  };
}
