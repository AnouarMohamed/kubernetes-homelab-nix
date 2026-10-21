{ inputs }:
let
  inherit (inputs) nixpkgs flake-utils;
  homelab = import ./config.nix;
in
flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
  system:
  let
    pkgs = import nixpkgs { inherit system; };
    sentinelPackages = import ./packages/sentinel.nix {
      inherit pkgs;
      inherit (inputs) self;
    };
    installer = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ ./iso ];
    };
    ciConfig = import ./ci;
    toolConfig = import ./tools { inherit homelab; };
    yamlFormat = pkgs.formats.yaml { };
    jsonFormat = pkgs.formats.json { };
    tomlFormat = pkgs.formats.toml { };
    generatedConfigs = pkgs.runCommand "homelab-generated-configs" { } ''
      mkdir -p "$out/.github/workflows"
      { echo '# GENERATED - DO NOT EDIT'; cat ${yamlFormat.generate "ci.yaml" ciConfig.github}; } > "$out/.github/workflows/ci.yaml"
      { echo '# GENERATED - DO NOT EDIT'; cat ${yamlFormat.generate "gitlab-ci.yml" ciConfig.gitlab}; } > "$out/.gitlab-ci.yml"
      { echo '# GENERATED - DO NOT EDIT'; cat ${yamlFormat.generate "sops.yaml" toolConfig.sops}; } > "$out/.sops.yaml"
      cp ${jsonFormat.generate "renovate.json" toolConfig.renovate} "$out/renovate.json"
      cp ${tomlFormat.generate "gitleaks.toml" toolConfig.gitleaks} "$out/.gitleaks.toml"
      cp ${jsonFormat.generate "markdownlint.json" toolConfig.markdownlint} "$out/.markdownlint.json"
    '';
    cloudflare = inputs.terranix.lib.terranixConfiguration {
      inherit pkgs;
      extraArgs = { inherit homelab; };
      modules = [ ./terranix/cloudflare.nix ];
    };
    manifests = import ./packages/manifests.nix {
      inherit pkgs homelab;
      inherit (pkgs) lib;
      inherit (inputs) kubenix;
    };
    schemas = import ./checks/schemas.nix { inherit pkgs; };
    render = pkgs.writeShellApplication {
      name = "render";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.git
      ];
      text = ''
        repository_root="$(git rev-parse --show-toplevel)"
        install -D --mode=0644 ${manifests} "$repository_root/rendered/all.yaml"
        cp -R ${generatedConfigs}/. "$repository_root/"
        echo "Rendered manifests to rendered/all.yaml"
      '';
    };
    noYaml = pkgs.runCommand "no-handwritten-yaml" { nativeBuildInputs = [ pkgs.findutils ]; } ''
      ${pkgs.bash}/bin/bash ${./checks/no-handwritten-yaml.sh} ${inputs.self}
      touch "$out"
    '';
    placeholders =
      pkgs.runCommand "documented-placeholders" { nativeBuildInputs = [ pkgs.ripgrep ]; }
        ''
          ${pkgs.bash}/bin/bash ${./checks/placeholders.sh} ${inputs.self}
          touch "$out"
        '';
    semanticParity = pkgs.runCommand "semantic-parity" { nativeBuildInputs = [ pkgs.ripgrep ]; } ''
      ${pkgs.bash}/bin/bash ${./checks/semantic-parity.sh} ${inputs.self}
      touch "$out"
    '';
    kubeconform = pkgs.runCommand "kubeconform" { nativeBuildInputs = [ pkgs.kubeconform ]; } ''
      kubeconform -strict -summary -ignore-missing-schemas \
        -schema-location 'file://${schemas}/builtin/{{.ResourceKind}}{{.KindSuffix}}.json' \
        -schema-location 'file://${schemas}/crd/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
        ${manifests}
      touch "$out"
    '';
    drift = pkgs.runCommand "rendered-manifest-drift" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      diff -u ${inputs.self}/rendered/all.yaml ${manifests}
      touch "$out"
    '';
    configDrift =
      pkgs.runCommand "generated-config-drift" { nativeBuildInputs = [ pkgs.diffutils ]; }
        ''
          diff -u ${inputs.self}/.github/workflows/ci.yaml ${generatedConfigs}/.github/workflows/ci.yaml
          diff -u ${inputs.self}/.gitlab-ci.yml ${generatedConfigs}/.gitlab-ci.yml
          diff -u ${inputs.self}/.sops.yaml ${generatedConfigs}/.sops.yaml
          diff -u ${inputs.self}/renovate.json ${generatedConfigs}/renovate.json
          diff -u ${inputs.self}/.gitleaks.toml ${generatedConfigs}/.gitleaks.toml
          diff -u ${inputs.self}/.markdownlint.json ${generatedConfigs}/.markdownlint.json
          touch "$out"
        '';
  in
  {
    formatter = pkgs.nixfmt-tree;
    packages = {
      inherit manifests;
      generated-configs = generatedConfigs;
      inherit cloudflare;
      inherit (pkgs) statix;
      inherit (sentinelPackages) sentinel sentinel-api-image sentinel-worker-image;
      installer-iso = installer.config.system.build.isoImage;
      default = manifests;
    };
    apps = {
      render = flake-utils.lib.mkApp { drv = render; };
      default = flake-utils.lib.mkApp { drv = render; };
    };
    checks = {
      inherit
        manifests
        noYaml
        placeholders
        semanticParity
        kubeconform
        drift
        configDrift
        ;
      inherit cloudflare;
      nixfmt = pkgs.runCommand "nixfmt" { nativeBuildInputs = [ pkgs.nixfmt-tree ]; } ''
        mkdir source
        cp -R --dereference ${inputs.self}/. source/
        chmod -R u+w source
        cd source
        treefmt --ci --tree-root "$PWD"
        touch "$out"
      '';
      statix = pkgs.runCommand "statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
        statix check ${inputs.self}
        touch "$out"
      '';
      deadnix = pkgs.runCommand "deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
        deadnix --fail ${inputs.self}
        touch "$out"
      '';
      gitleaks = pkgs.runCommand "gitleaks" { nativeBuildInputs = [ pkgs.gitleaks ]; } ''
        gitleaks dir --no-banner --redact --config ${inputs.self}/.gitleaks.toml ${inputs.self}
        touch "$out"
      '';
      inherit (sentinelPackages) sentinel;
      inherit (sentinelPackages) sentinel-api-image;
      inherit (sentinelPackages) sentinel-worker-image;
      kyverno = import ./checks/kyverno.nix { inherit pkgs; };
      k3s-ha = import ./tests/k3s-ha.nix { inherit pkgs; };
      node1 = inputs.self.nixosConfigurations.node1.config.system.build.toplevel;
      node2 = inputs.self.nixosConfigurations.node2.config.system.build.toplevel;
      node3 = inputs.self.nixosConfigurations.node3.config.system.build.toplevel;
      installer-iso = installer.config.system.build.isoImage;
    };
  }
)
// {
  nixosConfigurations = builtins.listToAttrs (
    map (node: {
      inherit (node) name;
      value = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit node; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          ./hosts
        ];
      };
    }) homelab.nodes
  );
  lib = {
    inherit homelab;
    helpers = import ./lib { inherit (nixpkgs) lib; };
  };
}
