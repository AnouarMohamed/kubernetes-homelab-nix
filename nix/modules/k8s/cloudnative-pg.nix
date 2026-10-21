{ kubenix, lib, pkgs, homelab, ... }:
let
  charts = import ../../lib/charts.nix { inherit pkgs; };
  substitute = import ../../lib/substitute.nix { inherit lib homelab; };
in
{
  imports = [ kubenix.modules.k8s kubenix.modules.helm ];
  kubernetes = {
    project = "kubernetes-homelab-nix";
    version = "1.36";
    customResources = map substitute (import ./resources/cloudnative-pg.nix);
    helm.releases = {
      cloudnative-pg = {
        chart = charts.cnpg;
        namespace = "cnpg-system";
        values = substitute (builtins.head (import ./values/cloudnative-pg.nix));
        includeCRDs = true;
        noHooks = true;
      };
      barman-cloud = {
        chart = charts.barman;
        namespace = "cnpg-system";
        values = substitute (builtins.head (import ./values/barman.nix));
        includeCRDs = true;
        noHooks = true;
      };
    };
  };
}

