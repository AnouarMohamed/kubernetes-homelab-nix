{ config, lib, ... }:
{
  # Verified against the pinned nixpkgs revision and the reference machine.
  # All three nodes are the same i7-8650U/32 GiB/SATA hardware class.
  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"
    "xhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # A small compressed swap tier absorbs short control-plane bursts without
  # adding write-heavy disk swap to the Longhorn hosts.
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  assertions = [
    {
      assertion =
        config.homelab.hardwareProfile.cores == 4 && config.homelab.hardwareProfile.threads == 8;
      message = "The reference hardware profile expects an i7-8650U with 4 cores and 8 threads.";
    }
    {
      assertion = config.homelab.hardwareProfile.memoryGiB >= 32;
      message = "Each reference node must have at least 32 GiB RAM.";
    }
    {
      assertion = builtins.all (
        node:
        node.installDisk == config.homelab.hardwareProfile.installDisk
        && node.interface == config.homelab.hardwareProfile.interface
      ) config.homelab.nodes;
      message = "All three nodes must use the shared, physically verified hardware profile.";
    }
  ];
}
