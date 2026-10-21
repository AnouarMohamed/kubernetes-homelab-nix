{
  kubenix,
  lib,
  homelab,
  resources ? [ ],
  ...
}:
let
  substitute = import ../../../lib/substitute.nix { inherit lib homelab; };
  renderedResources = map substitute resources;
in
{
  imports = [
    kubenix.modules.k8s
    (import ./resources.nix {
      inherit lib;
      resources = renderedResources;
    })
  ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = "1.36";
  };
}
