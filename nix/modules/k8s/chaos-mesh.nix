{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "chaos-mesh";
  namespace = "chaos-mesh";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).chaos-mesh;
  values = builtins.head (import ./values/chaos-mesh.nix);
}

