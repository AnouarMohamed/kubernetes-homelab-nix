{ homelab }:
{
  sops = {
    creation_rules =
      if homelab.ageRecipient == null then
        [ ]
      else
        [
          {
            path_regex = "secrets/.*\\.(json|yaml)$";
            age = homelab.ageRecipient;
          }
        ];
  };
  renovate = {
    extends = [ "config:recommended" ];
    dependencyDashboard = true;
    labels = [
      "dependencies"
      "nix"
    ];
    nix.enabled = true;
    schedule = [ "before 6am on monday" ];
  };
  gitleaks = {
    title = "kubernetes-homelab-nix";
    extend.useDefault = true;
  };
  markdownlint = {
    default = true;
    MD013 = false;
    MD033 = false;
  };
}
