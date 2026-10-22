{ node, ... }:
{
  imports = [
    ../modules/homelab-options.nix
    ../modules/os
    ./disko.nix
    ./hardware-profile.nix
  ];

  networking.hostName = node.name;
  homelab = (import ../config.nix) // {
    nodes = [
      node
    ]
    ++ builtins.filter (candidate: candidate.name != node.name) (import ../config.nix).nodes;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  networking.useDHCP = true;
  system.stateVersion = "26.05";
}
