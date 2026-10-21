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
}

