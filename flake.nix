{
  description = "A very basic flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-24.11"; 
    };

    # For user packages and dotfiles
    home-manager = {
      # TODO: update this to 25.05 when it's out
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # use system packages list where available
    };

    # A modified blender that works with Nvidia's proprietary CUDA stuff
    blender-bin-flake = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    blender-bin-flake,
    ...
  }@inputs: {
    # the rec keyword allows the attrset to self-reference, obviating a let-in stmt.
    nixosConfigurations.hypergamma = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      # specialArgs are added to the inputs of all modules
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          allowUnfree = true;
        };

        # make flake inputs available why not
        flake-inputs = inputs // {inherit system;};
      };
      modules = [
        ./hosts/hypergamma/configuration.nix
      ];
    };

    nixosConfigurations.goblin = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      # specialArgs are added to the inputs of all modules
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          allowUnfree = true;
        };
        # make flake inputs available why not
        flake-inputs = inputs // {inherit system;};
      };
      modules = [
        ./hosts/goblin/configuration.nix
      ];
    };

  };
}
