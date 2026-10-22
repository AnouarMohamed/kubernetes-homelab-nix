{ config, lib, ... }:
lib.mkIf (config.homelab.sopsFile != null) {
  # Ciphertext may enter the Nix store; decrypted values are materialized only
  # in /run. The private deployment module owns the encrypted source file.
  sops = {
    defaultSopsFile = config.homelab.sopsFile;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets.k3s-token.mode = "0400";
    secrets.cloudflare-tunnel-credentials.mode = "0400";
  };
}
