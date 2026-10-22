{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  image.fileName = "kubernetes-homelab-nix-installer.iso";
  # The installer never imports a ZFS root. Explicit false matches the pinned
  # 26.05 safety default and prevents accidental import of an existing pool.
  boot.zfs.forceImportRoot = false;
  networking.hostName = "homelab-installer";
  system.stateVersion = "26.05";
}
