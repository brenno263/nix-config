{
  description = "A very basic flake";

  inputs = {
    # Use the unstable branch by default, stable branch as a fallback.
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };

    # For configuring user packages and dotfiles
    home-manager = {
      # we follow master to align best with nixos-unstable.
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # use system packages list where available
    };

    # Secrets Management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom hardware tweaks
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs =
    # collects all inputs into `inputs` attrset
    { ... }@inputs:
    let
      # A templating function for a nixos configuration
      # the `rec` keyword lets an attrset self-reference
      mkConfiguration =
        { system, modules }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          inherit modules;

          # specialArgs are added to the inputs of all modules
          specialArgs = {
            # Expose stable nixpkgs
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
              allowUnfree = true;
            };

            # Make flake inputs and system available thru catchall "flake-inputs"
            flake-inputs = inputs // {
              inherit system;
            };
          };
        };
    in
    {
      nixosConfigurations = {
        hypergamma = mkConfiguration {
          system = "x86_64-linux";
          modules = [
            ./hosts/hypergamma/configuration.nix
            inputs.agenix.nixosModules.default
          ];
        };

        goblin = mkConfiguration {
          system = "x86_64-linux";
          modules = [
            ./hosts/goblin/configuration.nix
            inputs.agenix.nixosModules.default
          ];
        };

        aj-framework = mkConfiguration {
          system = "x86_64-linux";
          modules = [
            ./hosts/aj-framework/configuration.nix
            inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
          ];
        };

        lucy = mkConfiguration {
          system = "x86_64-linux";
          modules = [
            ./hosts/lucy/configuration.nix
            inputs.agenix.nixosModules.default
          ];
        };

        # more configs here
        # my-hostname = mkConfiguration {
        #   system = "x86_64-linux";
        #   modules = [
        #     ./hosts/lucy/my-hostname
        #     whatever-else
        #   ];
        # };

      };
    };
}
