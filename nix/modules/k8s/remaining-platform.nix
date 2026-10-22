{
  kubenix,
  lib,
  homelab,
  ...
}:
let
  substitute = import ../../lib/substitute.nix { inherit lib homelab; };
  normalize = import ./lib/normalize.nix { inherit lib; };
  resources = normalize.prepare {
    resources = import ./resources/remaining-platform.nix;
    byPartOf."resilience-testing" = "chaos-testing";
    byName."whoami-gateway" = "apps-whoami";
    dropUnnamedNetworkPolicyTemplates = true;
    dropLegacySnapshotController = true;
  };
in
{
  imports = [
    kubenix.modules.k8s
    (import ./lib/resources.nix {
      inherit lib;
      resources = map substitute resources;
    })
  ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = homelab.kubernetes.minor;
  };
}
