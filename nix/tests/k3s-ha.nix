{ pkgs }:
let
  tokenFile = pkgs.writeText "k3s-test-token" "build-only-test-token";
  pauseRoot = pkgs.buildEnv {
    name = "pause-root";
    paths = [ pkgs.coreutils ];
  };
  pauseImage = pkgs.dockerTools.buildImage {
    name = "test.local/pause";
    tag = "local";
    copyToRoot = pauseRoot;
    config.Entrypoint = [ "/bin/sleep" "infinity" ];
  };
  deployment = (pkgs.formats.yaml { }).generate "reschedule.yaml" {
    apiVersion = "apps/v1";
    kind = "Deployment";
    metadata.name = "reschedule-test";
    spec = {
      replicas = 1;
      selector.matchLabels.app = "reschedule-test";
      template = {
        metadata.labels.app = "reschedule-test";
        spec = {
          terminationGracePeriodSeconds = 0;
          containers = [ {
            name = "pause";
            image = "test.local/pause:local";
            imagePullPolicy = "Never";
          } ];
        };
      };
    };
  };
  common = { config, ... }: {
    virtualisation = { memorySize = 1536; diskSize = 4096; };
    networking.firewall.enable = false;
    environment.systemPackages = [ pkgs.kubectl pkgs.jq ];
    environment.sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    services.k3s = {
      enable = true;
      role = "server";
      inherit tokenFile;
      images = [ pauseImage ];
      nodeIP = config.networking.primaryIPAddress;
      disable = [ "local-storage" "metrics-server" "servicelb" "traefik" ];
      extraFlags = [
        "--flannel-iface=eth1"
        "--kube-controller-manager-arg=node-monitor-grace-period=10s"
        "--pause-image=test.local/pause:local"
      ];
    };
  };
in
pkgs.testers.runNixOSTest {
  name = "k3s-ha";
  nodes = {
    node1 = { ... }: {
      imports = [ common ];
      services.k3s.clusterInit = true;
    };
    node2 = { nodes, ... }: {
      imports = [ common ];
      services.k3s.serverAddr = "https://${nodes.node1.networking.primaryIPAddress}:6443";
    };
    node3 = { nodes, ... }: {
      imports = [ common ];
      services.k3s.serverAddr = "https://${nodes.node1.networking.primaryIPAddress}:6443";
    };
  };
  testScript = ''
    node1.start()
    node1.wait_for_unit("k3s")
    node2.start()
    node3.start()
    node2.wait_for_unit("k3s")
    node3.wait_for_unit("k3s")

    node1.wait_until_succeeds("test $(kubectl get nodes --no-headers | wc -l) -eq 3", timeout=300)
    node1.succeed("kubectl wait --for=condition=Ready nodes --all --timeout=300s")
    node1.succeed("kubectl apply -f ${deployment}")
    node1.succeed("kubectl rollout status deployment/reschedule-test --timeout=180s")

    original = node1.succeed("kubectl get pod -l app=reschedule-test -o jsonpath='{.items[0].spec.nodeName}'").strip()
    machine_by_name = {"node1": node1, "node2": node2, "node3": node3}
    machine_by_name[original].shutdown()
    survivor = node2 if original != "node2" else node3
    survivor.wait_until_succeeds("kubectl get --raw=/readyz", timeout=120)
    survivor.wait_until_succeeds(
      "test $(kubectl get pod -l app=reschedule-test --field-selector=status.phase=Running -o name | wc -l) -eq 1",
      timeout=420,
    )
    replacement = survivor.succeed("kubectl get pod -l app=reschedule-test -o jsonpath='{.items[?(@.status.phase==\"Running\")].spec.nodeName}'").strip()
    assert replacement != original, f"pod did not reschedule: {original}"
  '';
}

