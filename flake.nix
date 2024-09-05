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
