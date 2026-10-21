{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "argo-rollouts";
  namespace = "argo-rollouts";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).argo-rollouts;
  values = builtins.head (import ./values/argo-rollouts.nix);
}

