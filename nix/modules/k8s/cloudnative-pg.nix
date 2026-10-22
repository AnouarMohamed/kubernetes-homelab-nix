{
  kubenix,
  lib,
  homelab,
  ...
}:
let
  substitute = import ../../lib/substitute.nix { inherit lib homelab; };
in
{
  imports = [
    kubenix.modules.k8s
    (import ./lib/resources.nix {
      inherit lib;
      resources = map substitute (import ./resources/cloudnative-pg.nix);
    })
  ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = homelab.kubernetes.minor;
  };
}
