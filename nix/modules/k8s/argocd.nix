{ kubenix, lib, pkgs, homelab, ... }:
import ./lib/component.nix {
  inherit kubenix lib pkgs homelab;
  name = "argocd";
  namespace = "argocd";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).argocd;
  values = builtins.head (import ./values/argocd.nix);
  resources = import ./resources/argocd.nix;
}

