{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "longhorn";
  namespace = "longhorn-system";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).longhorn;
  values = builtins.head (import ./values/longhorn.nix);
  resources = import ./resources/longhorn.nix;
}

