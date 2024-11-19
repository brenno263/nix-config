{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # For user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # use system packages list where available
    };

    # A modified blender that works with Nvidia's proprietary CUDA stuff
    blender-bin-flake = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.hypergamma = let
      system = "x86_64-linux";
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inputs = inputs // { system = system; };
      };
      modules = [
        ./hosts/hypergamma/configuration.nix
      ];
    };
  };
}
