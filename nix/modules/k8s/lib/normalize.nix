{ lib }:
let
  identity =
    object:
    "${object.apiVersion}/${object.kind}/${
      object.metadata.namespace or "_cluster"
    }/${object.metadata.name}";

  # Only byte-for-byte equivalent conversion duplicates may be collapsed. A
  # conflicting identity aborts evaluation instead of relying on apply order.
  deduplicate =
    resources:
    builtins.attrValues (
      lib.foldl' (
        seen: object:
        let
          key = identity object;
        in
        if builtins.hasAttr key seen then
          if seen.${key} == object then
            seen
          else
            throw "Conflicting Kubernetes resources share identity ${key}"
        else
          seen // { ${key} = object; }
      ) { } resources
    );

  addNamespace =
    {
      byPartOf ? { },
      byName ? { },
    }:
    object:
    let
      metadata = object.metadata or { };
      labels = metadata.labels or { };
      partOf = labels."app.kubernetes.io/part-of" or "";
      namespace = byPartOf.${partOf} or (byName.${metadata.name or ""} or null);
    in
    if metadata ? namespace || namespace == null then
      object
    else
      object
      // {
        metadata = metadata // {
          inherit namespace;
        };
      };
in
{
  inherit deduplicate;

  prepare =
    {
      resources,
      byPartOf ? { },
      byName ? { },
      dropKinds ? [ ],
      dropNames ? { },
      dropUnnamedNetworkPolicyTemplates ? false,
      dropLegacySnapshotController ? false,
    }:
    let
      keep =
        object:
        let
          metadata = object.metadata or { };
          isUnnamedNetworkPolicyTemplate =
            dropUnnamedNetworkPolicyTemplates
            && object.kind == "NetworkPolicy"
            && !(metadata ? namespace)
            && builtins.elem (metadata.name or "") [
              "allow-dns-egress"
              "allow-intra-namespace"
              "deny-egress-by-default"
              "deny-ingress-by-default"
            ];
          isLegacySnapshotController =
            dropLegacySnapshotController
            && object.kind == "Deployment"
            && (metadata.name or "") == "snapshot-controller"
            && !(metadata ? labels);
        in
        !(builtins.elem object.kind dropKinds)
        && !(builtins.elem (metadata.name or "") (dropNames.${object.kind} or [ ]))
        && !isUnnamedNetworkPolicyTemplate
        && !isLegacySnapshotController;
    in
    deduplicate (map (addNamespace { inherit byPartOf byName; }) (builtins.filter keep resources));
}
