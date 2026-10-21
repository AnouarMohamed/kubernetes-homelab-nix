{ pkgs, lib, self }:
let
  sentinel = pkgs.buildGoModule {
    pname = "homelab-sentinel";
    version = "0.1.0";
    src = self + /apps/sentinel;
    vendorHash = lib.fakeHash;
    subPackages = [ "cmd/api" "cmd/worker" ];
    ldflags = [ "-s" "-w" ];
  };
  image = name: command: pkgs.dockerTools.buildLayeredImage {
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

