{ ... }:
{
  # Build-only layout. A real deployment must override the disk by-id value.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/REPLACE_WITH_INSTALL_DISK";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}

