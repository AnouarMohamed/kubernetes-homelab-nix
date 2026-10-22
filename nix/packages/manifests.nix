{
  pkgs,
  lib,
  kubenix,
  homelab,
}:
let
  charts = import ../lib/charts.nix { inherit pkgs; };
  bootstrapCrds = import ../lib/crds.nix { inherit pkgs; };
  substitute = import ../lib/substitute.nix { inherit lib homelab; };
  kubernetes = kubenix.evalModules.${pkgs.stdenv.hostPlatform.system} {
    module = import ../modules/k8s/all.nix;
    specialArgs = { inherit homelab; };
  };
  release =
    {
      name,
      namespace,
      chart,
      values,
      valuesOverride ? { },
      namespaceMissingKinds ? [ ],
    }:
    let
      renderedValues = lib.recursiveUpdate (substitute (builtins.head values)) valuesOverride;
      valuesFile = (pkgs.formats.json { }).generate "${name}-values.json" renderedValues;
    in
    pkgs.runCommand "${name}-helm-manifests.yaml"
      {
        nativeBuildInputs = [
          pkgs.kubernetes-helm
          pkgs.yq-go
        ];
      }
      ''
        helm template ${name} ${chart} \
          --namespace ${namespace} \
          --kube-version ${homelab.kubernetes.version} \
          --api-versions cert-manager.io/v1 \
          --api-versions gateway.networking.k8s.io/v1 \
          --api-versions cilium.io/v2 \
          --api-versions cilium.io/v2alpha1 \
          --include-crds \
          --no-hooks \
          --values ${valuesFile} \
          | sed -E 's/(rollme: )"[[:alnum:]]{5}"/\1"nix-pinned"/' \
          > rendered.yaml
        ${lib.optionalString (namespaceMissingKinds != [ ]) ''
          yq eval '(
            select(
              .metadata.namespace == null
              and .kind == "${lib.concatStringsSep "\" or .kind == \"" namespaceMissingKinds}"
            ) | .metadata.namespace
          ) = "${namespace}"' rendered.yaml > "$out"
        ''}
        ${lib.optionalString (namespaceMissingKinds == [ ]) ''
          cp rendered.yaml "$out"
        ''}
      '';
  releases = [
    {
      name = "cilium";
      namespace = "kube-system";
      chart = charts.cilium;
      values = import ../modules/k8s/values/cilium.nix;
      valuesOverride.devices = map (node: node.interface) homelab.nodes;
    }
    {
      name = "argocd";
      namespace = "argocd";
      chart = charts.argocd;
      values = import ../modules/k8s/values/argocd.nix;
    }
    {
      name = "longhorn";
      namespace = "longhorn-system";
      chart = charts.longhorn;
      values = import ../modules/k8s/values/longhorn.nix;
    }
    {
      name = "cloudnative-pg";
      namespace = "cnpg-system";
      chart = charts.cnpg;
      values = import ../modules/k8s/values/cloudnative-pg.nix;
    }
    {
      name = "barman-cloud";
      namespace = "cnpg-system";
      chart = charts.barman;
      values = import ../modules/k8s/values/barman.nix;
    }
    {
      name = "velero";
      namespace = "velero";
      chart = charts.velero;
      values = import ../modules/k8s/values/velero.nix;
    }
    {
      name = "openbao";
      namespace = "openbao";
      chart = charts.openbao;
      values = import ../modules/k8s/values/openbao.nix;
      namespaceMissingKinds = [ "NetworkPolicy" ];
    }
    {
      name = "external-secrets";
      namespace = "external-secrets";
      chart = charts.external-secrets;
      values = import ../modules/k8s/values/external-secrets.nix;
    }
    {
      name = "argo-rollouts";
      namespace = "argo-rollouts";
      chart = charts.argo-rollouts;
      values = import ../modules/k8s/values/argo-rollouts.nix;
    }
    {
      name = "cert-manager";
      namespace = "cert-manager";
      chart = charts.cert-manager;
      values = import ../modules/k8s/values/cert-manager.nix;
    }
    {
      name = "chaos-mesh";
      namespace = "chaos-mesh";
      chart = charts.chaos-mesh;
      values = import ../modules/k8s/values/chaos-mesh.nix;
    }
    {
      name = "external-dns";
      namespace = "external-dns";
      chart = charts.external-dns;
      values = import ../modules/k8s/values/external-dns.nix;
    }
    {
      name = "kube-prometheus-stack";
      namespace = "monitoring";
      chart = charts.prometheus-stack;
      values = import ../modules/k8s/values/prometheus-stack.nix;
    }
    {
      name = "blackbox-exporter";
      namespace = "monitoring";
      chart = charts.blackbox;
      values = import ../modules/k8s/values/blackbox.nix;
    }
    {
      name = "loki";
      namespace = "monitoring";
      chart = charts.loki;
      values = import ../modules/k8s/values/loki.nix;
    }
    {
      name = "alloy";
      namespace = "monitoring";
      chart = charts.alloy;
      values = import ../modules/k8s/values/alloy.nix;
    }
    {
      name = "tempo";
      namespace = "monitoring";
      chart = charts.tempo;
      values = import ../modules/k8s/values/tempo.nix;
    }
    {
      name = "otel-collector";
      namespace = "monitoring";
      chart = charts.otel;
      values = import ../modules/k8s/values/otel.nix;
    }
    {
      name = "sloth";
      namespace = "monitoring";
      chart = charts.sloth;
      values = import ../modules/k8s/values/sloth.nix;
    }
    {
      name = "kyverno";
      namespace = "kyverno";
      chart = charts.kyverno;
      values = import ../modules/k8s/values/kyverno.nix;
    }
    {
      name = "trivy-operator";
      namespace = "trivy-system";
      chart = charts.trivy;
      values = import ../modules/k8s/values/trivy.nix;
    }
  ];
  renderedCharts = map release releases;
in
pkgs.runCommand "kubernetes-homelab-manifests.yaml" { } ''
  {
    echo '# GENERATED - DO NOT EDIT'
    echo '# Source: Nix modules in nix/modules/k8s'
    cat ${bootstrapCrds}
    echo '---'
    cat ${kubernetes.config.kubernetes.resultYAML}
    ${lib.concatMapStringsSep "\n" (chart: "cat ${chart}") renderedCharts}
  } | sed -E 's/[[:space:]]+$//' > "$out"
''
