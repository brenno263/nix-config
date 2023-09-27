{
  description = "Brennan Seymour's Nixos flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, ...}@inputs: {
    nixosConfigurations = {
      lucy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	specialArgs = inputs;
        modules = [
          nixos-hardware.nixosModules.system76
          ./configuration.nix
	  ./hardware-configuration.nix
          ./modules/gnome.nix
          ./modules/spotify.nix
          ./modules/discord.nix
          ({pkgs, ...}: {
            environment.systemPackages = with pkgs; [
              godot
              signal-desktop
            ];
          })
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ({pkgs, ...}: {
            nix.registry = {
              nixpkgs.flake = nixpkgs;
              nixos-hardware.flake = nixos-hardware;
            };
          })
        ];
      };
    };
  };
}
