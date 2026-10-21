{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "external-secrets";
  namespace = "external-secrets";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).external-secrets;
  values = builtins.head (import ./values/external-secrets.nix);
}

