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
  name = "openbao";
  namespace = "openbao";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).openbao;
  values = builtins.head (import ./values/openbao.nix);
  resources = import ./resources/openbao.nix;
}
