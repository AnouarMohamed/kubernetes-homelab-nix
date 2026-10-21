{ kubenix, lib, pkgs, homelab, name, namespace, chart ? null, values ? { }, resources ? [ ], valuesOverride ? { } }:
let
  substitute = import ../../../lib/substitute.nix { inherit lib homelab; };
in
{
  imports = [ kubenix.modules.k8s ] ++ lib.optional (chart != null) kubenix.modules.helm;
  kubenix.project = "kubernetes-homelab-nix";
  kubernetes = {
    version = "1.36";
    customResources = map substitute resources;
    helm.releases = lib.optionalAttrs (chart != null) {
      ${name} = {
        inherit chart namespace;
        values = lib.recursiveUpdate (substitute values) valuesOverride;
        includeCRDs = true;
        noHooks = true;
      };
    };
  };
}
