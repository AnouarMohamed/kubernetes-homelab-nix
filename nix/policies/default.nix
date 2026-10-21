{ kubenix, lib, pkgs, homelab, ... }:
let
  charts = import ../lib/charts.nix { inherit pkgs; };
  substitute = import ../lib/substitute.nix { inherit lib homelab; };
  release = namespace: chart: values: {
    inherit namespace chart;
    values = substitute (builtins.head values);
    includeCRDs = true;
    noHooks = true;
  };
in
{
  imports = [ kubenix.modules.k8s kubenix.modules.helm ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = "1.36";
    customResources = map substitute (import ./resources.nix);
    helm.releases = {
      kyverno = release "kyverno" charts.kyverno (import ../modules/k8s/values/kyverno.nix);
      trivy-operator = release "trivy-system" charts.trivy (import ../modules/k8s/values/trivy.nix);
    };
  };
}

