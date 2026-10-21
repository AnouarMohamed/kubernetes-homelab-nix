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
    lib = {
      inherit homelab;
      helpers = import ./lib { lib = nixpkgs.lib; };
    };
  }
