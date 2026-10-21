{
  imports = [
    ./core.nix
    ./argo-rollouts.nix
    ./cert-manager.nix
    ./chaos-mesh.nix
    ./external-dns.nix
    ./remaining-platform.nix
    ./observability.nix
  ];
}
