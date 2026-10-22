{ node, ... }:
{
  # Destructive installation is impossible until each node's stable disk ID is
  # replaced in the private deployment configuration.
  disko.devices.disk.main = {
    type = "disk";
    device = node.installDisk;
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
