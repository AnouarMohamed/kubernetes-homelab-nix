{ lib, resources }:
let
  nativeGroups = [
    "core"
    "admissionregistration.k8s.io"
    "apiextensions.k8s.io"
    "apps"
    "authentication.k8s.io"
    "authorization.k8s.io"
    "autoscaling"
    "batch"
    "certificates.k8s.io"
    "coordination.k8s.io"
    "discovery.k8s.io"
    "events.k8s.io"
    "flowcontrol.apiserver.k8s.io"
    "networking.k8s.io"
    "node.k8s.io"
    "policy"
    "rbac.authorization.k8s.io"
    "resource.k8s.io"
    "scheduling.k8s.io"
    "storage.k8s.io"
  ];
  parse = object:
    let parts = lib.splitString "/" object.apiVersion;
    in {
      group = if builtins.length parts == 1 then "core" else builtins.head parts;
      version = builtins.elemAt parts (builtins.length parts - 1);
      inherit (object) kind;
    };
  sanitize = value: lib.toLower (builtins.replaceStrings [ "/" "." "_" ":" ] [ "-" "-" "-" "-" ] value);
  typesByKey = builtins.listToAttrs (map (object:
    let type = parse object; key = "${type.group}-${type.version}-${type.kind}";
    in {
      name = key;
      value = type // { attrName = sanitize key; };
    }) (builtins.filter (object: !(builtins.elem (parse object).group nativeGroups)) resources));
  definitions = lib.imap0 (index: object:
    let
      type = parse object;
      namespace = object.metadata.namespace or "cluster";
      key = sanitize "${namespace}-${object.metadata.name}-${toString index}";
    in
    lib.setAttrByPath [ type.group type.version type.kind key ] object
  ) resources;
in
{
  kubernetes.customTypes = builtins.attrValues typesByKey;
  kubernetes.api.resources = lib.mkMerge definitions;
}

