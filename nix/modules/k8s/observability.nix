{ kubenix, lib, pkgs, homelab, ... }:
let
  charts = import ../../lib/charts.nix { inherit pkgs; };
  substitute = import ../../lib/substitute.nix { inherit lib homelab; };
  release = chart: values: {
    inherit chart;
    namespace = "monitoring";
    values = substitute (builtins.head values);
    includeCRDs = true;
    noHooks = true;
  };
in
{
  imports = [ kubenix.modules.k8s kubenix.modules.helm ];
  kubernetes = {
    project = "kubernetes-homelab-nix";
    version = "1.36";
    customResources = map substitute (import ./resources/observability.nix);
    helm.releases = {
      kube-prometheus-stack = release charts.prometheus-stack (import ./values/prometheus-stack.nix);
      blackbox-exporter = release charts.blackbox (import ./values/blackbox.nix);
      loki = release charts.loki (import ./values/loki.nix);
      alloy = release charts.alloy (import ./values/alloy.nix);
      tempo = release charts.tempo (import ./values/tempo.nix);
      otel-collector = release charts.otel (import ./values/otel.nix);
      sloth = release charts.sloth (import ./values/sloth.nix);
    };
  };
}

