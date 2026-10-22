{ pkgs }:
let
  ciliumSource = pkgs.fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "v1.20.2";
    hash = "sha256-F8zFd3jsvgn64WnYgzGQPUIt6b8l4/yUlncTyVLCQCc=";
  };
  gatewayApi = pkgs.fetchurl {
    # Cilium 1.20.2's locked Go module uses Gateway API v1.6.1.
    url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml";
    hash = "sha256-JNkx8iq9jkDJcyZDGerXz6CdD7dxa3qx7i/xdMsGOnM=";
  };
in
pkgs.runCommand "homelab-bootstrap-crds.yaml" { } ''
  {
    echo '# GENERATED - DO NOT EDIT'
    echo '# Gateway API v1.6.1 and Cilium v1.20.2 CRDs'
    cat ${gatewayApi}
    for crd in \
      ${ciliumSource}/pkg/k8s/apis/cilium.io/client/crds/v2/*.yaml \
      ${ciliumSource}/pkg/k8s/apis/cilium.io/client/crds/v2alpha1/*.yaml
    do
      echo '---'
      cat "$crd"
    done
  } > "$out"
''
