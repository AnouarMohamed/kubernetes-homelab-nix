{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  isoImage.isoName = "kubernetes-homelab-nix-installer.iso";
  networking.hostName = "homelab-installer";
  system.stateVersion = "26.05";
}

