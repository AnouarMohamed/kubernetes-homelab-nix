{ lib }:
{
  commonLabels = component: {
    "app.kubernetes.io/managed-by" = "nix";
    "app.kubernetes.io/part-of" = "kubernetes-homelab-nix";
    "app.kubernetes.io/component" = component;
  };

  restrictedSecurityContext = {
    allowPrivilegeEscalation = false;
    capabilities.drop = [ "ALL" ];
    readOnlyRootFilesystem = true;
    runAsNonRoot = true;
    seccompProfile.type = "RuntimeDefault";
  };

  enabled = config: name: config.components.${name} or false;

  sanitizeName = value:
    lib.toLower (builtins.replaceStrings [ "/" "_" "." ] [ "-" "-" "-" ] value);
}

