{
  pkgs,
  self,
}:
let
  sentinel = pkgs.buildGoModule {
    pname = "homelab-sentinel";
    version = "0.3.0";
    src = self + /apps/sentinel;
    vendorHash = "sha256-v1TY5m0+gwlUmf80KElo2NS5rrh+fNyLXHlvp5KSU+g=";
    # This portable-Nix environment advertises unreachable IPv6 routes. Use
    # libc's address ordering while fetching the fixed-output Go module graph.
    env.GODEBUG = "netdns=cgo";
    subPackages = [
      "cmd/api"
      "cmd/worker"
    ];
    ldflags = [
      "-s"
      "-w"
    ];
    # Go may create its cache below HOME. Keep that state inside the build
    # directory so unsandboxed builders do not leak /homeless-shelter.
    preBuild = ''
      export HOME="$TMPDIR"
    '';
  };
  image =
    name: command:
    pkgs.dockerTools.buildLayeredImage {
      inherit name;
      tag = "nix";
      contents = [ pkgs.cacert ];
      config = {
        Entrypoint = [ "${sentinel}/bin/${command}" ];
        User = "65532:65532";
        WorkingDir = "/";
      };
    };
in
{
  inherit sentinel;
  sentinel-api-image = image "homelab-sentinel-api" "api";
  sentinel-worker-image = image "homelab-sentinel-worker" "worker";
}
