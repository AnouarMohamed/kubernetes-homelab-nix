{ homelab }:
{
  sops = {
    creation_rules = [ {
      path_regex = "secrets/.*\\.(json|yaml)$";
      age = homelab.ageRecipient;
    } ];
  };
  renovate = {
    extends = [ "config:recommended" ];
    dependencyDashboard = true;
    labels = [ "dependencies" "nix" ];
    nix.enabled = true;
    schedule = [ "before 6am on monday" ];
  };
  gitleaks = {
    title = "kubernetes-homelab-nix";
    extend.useDefault = true;
    allowlist = {
      description = "Build-only placeholder ciphertext";
      paths = [ "secrets/placeholder.json" ];
    };
  };
  markdownlint = {
    default = true;
    MD013 = false;
    MD033 = false;
  };
}

