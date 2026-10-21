{ ... }:
{
  # Secret values are materialized only in /run; neither token enters the Nix store.
  sops.defaultSopsFile = ../../../secrets/placeholder.json;
  sops.defaultSopsFormat = "json";
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets.k3s-token = { mode = "0400"; };
  sops.secrets.cloudflare-tunnel-credentials = { mode = "0400"; };
}

