{
  github = {
    name = "Nix validation";
    "on" = {
      push.branches = [ "main" ];
      pull_request = { };
      workflow_dispatch = { };
    };
    permissions.contents = "read";
    jobs = {
      bootstrap = {
        runs-on = "ubuntu-24.04";
        steps = [
          { uses = "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803"; }
          {
            uses = "cachix/install-nix-action@448cde739abec1eaf0646249e3d25bb8d9bc7702";
            "with".extra_nix_config = "experimental-features = nix-command flakes";
          }
          {
            name = "Build manifests";
            run = "nix build .#manifests --print-build-logs";
          }
          {
            name = "Build generated configuration";
            run = "nix build .#generated-configs --out-link generated-result";
          }
          {
            name = "Build Sentinel";
            run = "nix build .#sentinel --print-build-logs";
          }
        ];
      };
      checks = {
        needs = [ "bootstrap" ];
        runs-on = "ubuntu-24.04";
        steps = [
          { uses = "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803"; }
          {
            uses = "cachix/install-nix-action@448cde739abec1eaf0646249e3d25bb8d9bc7702";
            "with".extra_nix_config = "experimental-features = nix-command flakes";
          }
          {
            name = "Evaluate flake";
            run = "nix flake show --all-systems";
          }
          {
            name = "Run checks";
            run = "nix flake check --keep-going --print-build-logs";
          }
        ];
      };
    };
  };

  gitlab = {
    stages = [ "validate" ];
    "nix:flake-check" = {
      stage = "validate";
      tags = [ "nix" ];
      script = [ "nix flake check --keep-going --print-build-logs" ];
    };
  };
}
