{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "velero";
  namespace = "velero";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).velero;
  values = builtins.head (import ./values/velero.nix);
  resources = import ./resources/velero.nix;
}

