{ config, pkgs, ... }:
{
  # Longhorn discovers these conventional FHS paths and requires iSCSI/NFS
  # helpers on every node. Keep this module even though no hardware is deployed.
  boot.kernelModules = [
    "iscsi_tcp"
    "dm_crypt"
  ];
  environment.systemPackages = [
    pkgs.openiscsi
    pkgs.nfs-utils
    pkgs.cryptsetup
  ];
  environment.etc."iscsi/iscsid.conf".text = "node.startup = automatic\n";
  systemd.services.iscsid = {
    description = "Open-iSCSI daemon for Longhorn";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.openiscsi}/bin/iscsid -f";
      Restart = "on-failure";
    };
  };
  systemd.tmpfiles.rules = [
    "d ${config.homelab.storage.longhornDiskPath} 0700 root root -"
    "L+ /usr/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
  ];
}
