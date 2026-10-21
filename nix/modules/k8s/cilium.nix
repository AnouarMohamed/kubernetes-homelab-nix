{
  kubenix,
  lib,
  pkgs,
  homelab,
  ...
}:
import ./lib/component.nix {
  inherit
    kubenix
    lib
    pkgs
    homelab
    ;
  name = "cilium";
  namespace = "kube-system";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).cilium;
  values = builtins.head (import ./values/cilium.nix);
  valuesOverride.devices = map (node: node.interface) homelab.nodes;
  resources = import ./resources/cilium.nix;
}
