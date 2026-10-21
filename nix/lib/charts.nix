{ pkgs }:
let
  fetch = { url, sha256 }: pkgs.fetchurl { inherit url sha256; };
in
{
  cilium = fetch {
    url = "https://helm.cilium.io/cilium-1.20.2.tgz";
    sha256 = "b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e";
  };
  argocd = fetch {
    url = "https://github.com/argoproj/argo-helm/releases/download/argo-cd-10.10.2/argo-cd-10.10.2.tgz";
    sha256 = "1f2bdb0e23b87fdac5222d99d1acf6964e670db9bf63912c58ab4677e505638b";
  };
  longhorn = fetch {
    url = "https://github.com/longhorn/charts/releases/download/longhorn-1.12.1/longhorn-1.12.1.tgz";
    sha256 = "c8cf4b35a9d872cd5f7e44fd26d8e6ac7c2abaee42f4e2f2a0b0ebbc6e3a6116";
  };
  cnpg = fetch {
    url = "https://github.com/cloudnative-pg/charts/releases/download/cloudnative-pg-v0.29.1/cloudnative-pg-0.29.1.tgz";
    sha256 = "b53d3991fe84bcf38767e7702cae78666265427a127a26fff168ab4207d2b1df";
  };
  barman = fetch {
    url = "https://github.com/cloudnative-pg/charts/releases/download/plugin-barman-cloud-v0.8.1/plugin-barman-cloud-0.8.1.tgz";
    sha256 = "9ad0b9e56da2777a1a0269feaf7215e18297e9c8b5730e04acb27b5d462e9456";
  };
  velero = fetch {
    url = "https://github.com/vmware-tanzu/helm-charts/releases/download/velero-12.2.1/velero-12.2.1.tgz";
    sha256 = "fe4acd70a0123c369e7af7064457b4ffdddebee413e2bb01976a4fe07c471773";
  };
  openbao = fetch {
    url = "https://github.com/openbao/openbao-helm/releases/download/openbao-0.30.3/openbao-0.30.3.tgz";
    sha256 = "d50ed31b8305f430df308c342dd3c1efa877222380e99cb480f74f070d6beaa8";
  };
  external-secrets = fetch {
    url = "https://github.com/external-secrets/external-secrets/releases/download/helm-chart-2.12.0/external-secrets-2.12.0.tgz";
    sha256 = "4b584136b7311c0af8c8719d377cc5b1a7ef12c2de18f1fdb30614eab75bdeb3";
  };
  argo-rollouts = fetch {
    url = "https://github.com/argoproj/argo-helm/releases/download/argo-rollouts-2.41.1/argo-rollouts-2.41.1.tgz";
    sha256 = "ee4f2f7d848b5d675070fc6c3da55708507c4228da73eed22b4d7825edfccace";
  };
  cert-manager = fetch {
    url = "https://charts.jetstack.io/charts/cert-manager-v1.21.1.tgz";
    sha256 = "c27101f3f3e2349fb4a9e704316105bf7b52ad73b8c8257d3498ef7f2f6a4adc";
  };
  chaos-mesh = fetch {
    url = "https://charts.chaos-mesh.org/chaos-mesh-2.8.4.tgz";
    sha256 = "ae4abd385649771300e4d33a44627c0df3618be0780c385bf30cc2fdf2ad93fa";
  };
  external-dns = fetch {
    url = "https://github.com/kubernetes-sigs/external-dns/releases/download/external-dns-helm-chart-1.22.0/external-dns-1.22.0.tgz";
    sha256 = "ec26bba67e02f46a55ac33790ad9d9ded724a163af6f6b4a63ce68f883201f4f";
  };
  prometheus-stack = fetch {
    url = "https://github.com/prometheus-community/helm-charts/releases/download/kube-prometheus-stack-92.3.0/kube-prometheus-stack-92.3.0.tgz";
    sha256 = "48399b911fa91b353e0c3d5e32c1cb7a67a168566549723553154ffd7be5d1fa";
  };
  blackbox = fetch {
    url = "https://github.com/prometheus-community/helm-charts/releases/download/prometheus-blackbox-exporter-11.20.0/prometheus-blackbox-exporter-11.20.0.tgz";
    sha256 = "e341b17f202c7ff95cae056d23a481d8080aa3dc1dbaaa5d68296595b8b90ace";
  };
  loki = fetch {
    url = "https://github.com/grafana/helm-charts/releases/download/helm-loki-7.3.0/loki-7.3.0.tgz";
    sha256 = "04a339f712d770a1f599f05fc0a5a3cde18e43914e49ae6a49f7171be86bcc09";
  };
  alloy = fetch {
    url = "https://github.com/grafana/helm-charts/releases/download/alloy-1.13.1/alloy-1.13.1.tgz";
    sha256 = "6c2b7df23e39438bb11f1e1fcf19eb9eb7c8bfeab7d49b7c975b6212abd0f99a";
  };
  tempo = fetch {
    url = "https://github.com/grafana/helm-charts/releases/download/tempo-1.24.4/tempo-1.24.4.tgz";
    sha256 = "f1f6e318d5bca3b5097cb676077796cdf8135beb2c1f71c4d14614ccf9b0081b";
  };
  otel = fetch {
    url = "https://github.com/open-telemetry/opentelemetry-helm-charts/releases/download/opentelemetry-collector-0.175.1/opentelemetry-collector-0.175.1.tgz";
    sha256 = "33996399f5d831193603f8a56ed46b7cd3f012eeb6df4d5046c5b560a554e21d";
  };
  sloth = fetch {
    url = "https://github.com/slok/sloth/releases/download/sloth-helm-chart-0.16.0/sloth-0.16.0.tgz";
    sha256 = "616acb580eefc2e9836cc1b430cac6d424e0e4210130786b6ec883657217c6db";
  };
  kyverno = fetch {
    url = "https://kyverno.github.io/kyverno/kyverno-3.9.1.tgz";
    sha256 = "7b7fe51a431b5b133b0ce7eb9dcb222b6a37fb967c163223cf480054ad14d752";
  };
  trivy = fetch {
    url = "https://github.com/aquasecurity/helm-charts/releases/download/trivy-operator-0.37.0/trivy-operator-0.37.0.tgz";
    sha256 = "6d23f16d950496d17253258ca2e52bd068959041298e66c0652bf0841ccedf69";
  };
}

