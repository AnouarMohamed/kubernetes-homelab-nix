{ config, pkgs, ... }:
{
  time.timeZone = config.homelab.timezone;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    curl
    git
    jq
  ];

  users.mutableUsers = false;
  users.users.${config.homelab.adminUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ config.homelab.sshAuthorizedKey ];
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ config.homelab.adminUser ];
    };
  };
}
