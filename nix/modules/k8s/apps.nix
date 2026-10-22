{
  kubenix,
  lib,
  homelab,
  ...
}:
let
  substitute = import ../../lib/substitute.nix { inherit lib homelab; };
  normalize = import ./lib/normalize.nix { inherit lib; };
  resources = normalize.prepare {
    resources = import ./resources/apps.nix;
    byPartOf = {
      homepage = "apps-homepage";
      "uptime-kuma" = "apps-uptime-kuma";
      vaultwarden = "apps-vaultwarden";
      "homelab-sentinel" = "apps-sentinel";
      "homelab-platform" = "keycloak";
      "homelab-applications" = "apps-whoami";
    };
    byName = {
      whoami = "apps-whoami";
      "whoami-gateway" = "apps-whoami";
    };
  };
in
{
  imports = [
    kubenix.modules.k8s
    (import ./lib/resources.nix {
      inherit lib;
      resources = map substitute resources;
    })
  ];
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = homelab.kubernetes.minor;
  };
}
