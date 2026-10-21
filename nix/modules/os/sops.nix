_: {
  # Secret values are materialized only in /run; neither token enters the Nix store.
  sops = {
    defaultSopsFile = ../../../secrets/placeholder.json;
    defaultSopsFormat = "json";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets.k3s-token.mode = "0400";
    secrets.cloudflare-tunnel-credentials.mode = "0400";
  };
}
