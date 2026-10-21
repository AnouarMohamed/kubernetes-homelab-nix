{ inputs }:
let
  inherit (inputs) nixpkgs flake-utils;
  homelab = import ./config.nix;
in
flake-utils.lib.eachDefaultSystem (system:
  let pkgs = import nixpkgs { inherit system; }; in
  {
    formatter = pkgs.nixfmt-tree;
    packages.default = pkgs.writeText "scaffold" "Nix homelab scaffold\n";
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
