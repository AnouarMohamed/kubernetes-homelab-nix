{ kubenix, lib, homelab, ... }:
let substitute = import ../../lib/substitute.nix { inherit lib homelab; };
in {
  imports = [ kubenix.modules.k8s ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = "1.36";
    customResources = map substitute (import ./resources/remaining-platform.nix);
  };
}

