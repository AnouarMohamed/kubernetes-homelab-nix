{
  description = "Build-only NixOS and Kubernetes homelab reference platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
    kubenix = {
      url = "github:hall/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubernetes-json-schema = {
      url = "github:yannh/kubernetes-json-schema/b2ba4defe30ed5a0104987433896f1fd32807304";
      flake = false;
    };
    crds-catalog = {
      url = "github:datreeio/CRDs-catalog/501527ab9c40c827144c8f45945b25a023e344ce";
      flake = false;
    };
  };

  outputs = inputs: import ./nix/flake-outputs.nix { inherit inputs; };
}
