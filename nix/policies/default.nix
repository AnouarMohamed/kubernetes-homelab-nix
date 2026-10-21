{ kubenix, lib, homelab, ... }:
let
  substitute = import ../lib/substitute.nix { inherit lib homelab; };
in
{
  imports = [
    kubenix.modules.k8s
    (import ../modules/k8s/lib/resources.nix {
      inherit lib;
      resources = map substitute (import ./resources.nix);
    })
  ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = "1.36";
  };
}

