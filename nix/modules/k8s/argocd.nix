{
  kubenix,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  normalize = import ./lib/normalize.nix { inherit lib; };
  resources =
    normalize.prepare {
      resources = (import ./resources/argocd.nix) ++ (import ./resources/gitops.nix { inherit homelab; });
      dropKinds = [
        "Application"
        "ApplicationSet"
        "AppProject"
        "ksops"
      ];
      dropNames.Namespace = [ "cloudflare" ];
    }
    ++ (import ./resources/gitops.nix { inherit homelab; });
in
import ./lib/component.nix {
  inherit
    kubenix
    lib
    pkgs
    homelab
    ;
  name = "argocd";
  namespace = "argocd";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).argocd;
  values = builtins.head (import ./values/argocd.nix);
  inherit resources;
}
