{ inputs }:
let
  inherit (inputs) nixpkgs flake-utils;
  homelab = import ./config.nix;
in
flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    sentinelPackages = import ./packages/sentinel.nix {
      inherit pkgs;
      lib = pkgs.lib;
      self = inputs.self;
    };
    installer = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ ./iso ];
    };
    kubernetes = inputs.kubenix.evalModules.${system} {
      module = import ./modules/k8s/all.nix;
      specialArgs = { inherit homelab; };
    };
    rawManifests = kubernetes.config.kubernetes.resultYAML;
    manifests = pkgs.runCommand "kubernetes-homelab-manifests.yaml" { } ''
      {
        echo '# GENERATED - DO NOT EDIT'
        echo '# Source: Nix modules in nix/modules/k8s'
        cat ${rawManifests}
      } > "$out"
    '';
    render = pkgs.writeShellApplication {
      name = "render";
      runtimeInputs = [ pkgs.coreutils pkgs.git ];
      text = ''
        repository_root="$(git rev-parse --show-toplevel)"
        install -D --mode=0644 ${manifests} "$repository_root/rendered/all.yaml"
        echo "Rendered manifests to rendered/all.yaml"
      '';
    };
    noYaml = pkgs.runCommand "no-handwritten-yaml" { nativeBuildInputs = [ pkgs.findutils ]; } ''
      ${pkgs.bash}/bin/bash ${./checks/no-handwritten-yaml.sh} ${inputs.self}
      touch "$out"
    '';
    placeholders = pkgs.runCommand "documented-placeholders" { nativeBuildInputs = [ pkgs.ripgrep ]; } ''
      ${pkgs.bash}/bin/bash ${./checks/placeholders.sh} ${inputs.self}
      touch "$out"
    '';
    kubeconform = pkgs.runCommand "kubeconform" { nativeBuildInputs = [ pkgs.kubeconform ]; } ''
      kubeconform -strict -summary -ignore-missing-schemas \
        -schema-location 'file://${./checks/schemas}/{{.ResourceKind}}-{{.ResourceAPIVersion}}.json' \
        ${manifests}
      touch "$out"
    '';
    drift = pkgs.runCommand "rendered-manifest-drift" { nativeBuildInputs = [ pkgs.diffutils ]; } ''
      diff -u ${inputs.self}/rendered/all.yaml ${manifests}
      touch "$out"
    '';
  in
  {
    formatter = pkgs.nixfmt-tree;
    packages = {
      inherit manifests;
      inherit (sentinelPackages) sentinel sentinel-api-image sentinel-worker-image;
      installer-iso = installer.config.system.build.isoImage;
      default = manifests;
    };
    apps = {
      render = flake-utils.lib.mkApp { drv = render; };
      default = flake-utils.lib.mkApp { drv = render; };
    };
    checks = {
      inherit manifests noYaml placeholders kubeconform drift;
      nixfmt = pkgs.runCommand "nixfmt" { nativeBuildInputs = [ pkgs.nixfmt-tree ]; } ''
        nixfmt --check ${inputs.self}
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
        gitleaks dir --no-banner --redact ${inputs.self}
        touch "$out"
      '';
      sentinel = pkgs.runCommand "sentinel-tests" { nativeBuildInputs = [ pkgs.go ]; } ''
        export HOME="$TMPDIR/home"
        export GOCACHE="$TMPDIR/go-cache"
        export GOPATH="$TMPDIR/go"
        cp -R ${inputs.self}/apps/sentinel source
        chmod -R u+w source
        cd source
        go test ./...
        touch "$out"
      '';
      kyverno = import ./checks/kyverno.nix { inherit pkgs; };
      k3s-ha = import ./tests/k3s-ha.nix { inherit pkgs; };
      node1 = inputs.self.nixosConfigurations.node1.config.system.build.toplevel;
      node2 = inputs.self.nixosConfigurations.node2.config.system.build.toplevel;
      node3 = inputs.self.nixosConfigurations.node3.config.system.build.toplevel;
      installer-iso = installer.config.system.build.isoImage;
    };
  }) // {
    nixosConfigurations = builtins.listToAttrs (map (node: {
      name = node.name;
      value = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit node; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          ./hosts
        ];
      };
    }) homelab.nodes);
    lib = {
      inherit homelab;
      helpers = import ./lib { lib = nixpkgs.lib; };
    };
  }

