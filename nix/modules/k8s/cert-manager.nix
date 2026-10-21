{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "cert-manager";
  namespace = "cert-manager";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).cert-manager;
  values = builtins.head (import ./values/cert-manager.nix);
}

