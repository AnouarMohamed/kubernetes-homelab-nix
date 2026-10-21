{
  imports = [
    ./base.nix
    ./hardening.nix
    ./k3s-ha.nix
    ./kube-vip.nix
    ./storage-prereqs.nix
    ./cloudflared.nix
    ./sops.nix
    ./node-exporter.nix
  ];
}
