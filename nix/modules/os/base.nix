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
    kubectl
  ];

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [ config.homelab.sshAuthorizedKey ];
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
