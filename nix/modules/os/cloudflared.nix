{ config, lib, ... }:
{
  services.cloudflared = lib.mkIf config.homelab.hostTunnel.enable {
    enable = true;
    tunnels.${toString config.homelab.hostTunnel.tunnelId} = {
      credentialsFile = config.sops.secrets.cloudflare-tunnel-credentials.path;
      default = "http_status:404";
      warp-routing.enabled = true;
    };
  };
}
