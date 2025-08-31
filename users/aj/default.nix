{config, lib, pkgs, flake-inputs, ...}:
let
	cfg = config.userconfig.aj;
in {

	imports = [
		flake-inputs.home-manager.nixosModules.default
	];

	options.userconfig.aj = {
		enable = lib.mkEnableOption "user aj";
		hostname = lib.mkOption {
			defaultText = "hostname of the current system";
			type = lib.types.str;
		};
	};

	config = lib.mkIf cfg.enable {
		users.users.aj = {
			isNormalUser = true;
			description = "Amber Best";
			extraGroups = [ "networkmanager" "wheel" "docker" ];
			shell = pkgs.zsh;
			packages = with pkgs; [
				vscodium
				neovim
				kitty
			];
		};
		fonts.packages = with pkgs; [
			nerd-fonts.meslo-lg
		];
		programs.zsh.enable = true;
		home-manager = {
			users.aj = ./home.nix;
			extraSpecialArgs = {
				inherit flake-inputs;
				userConfiguration = cfg;
			};
		};
	};
}
