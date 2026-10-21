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
  name = "external-dns";
  namespace = "external-dns";
  chart = (import ../../lib/charts.nix { inherit pkgs; }).external-dns;
  values = builtins.head (import ./values/external-dns.nix);
}
