{config, lib, pkgs, flake-inputs, ...}:
let
	cfg = config.userconfig.b;
in {

	imports = [
		# pending https://discourse.nixos.org/t/services-kanata-attribute-lib-missing/51476
		./kanata.nix
		flake-inputs.home-manager.nixosModules.default
	];

	options.userconfig.b = {
		enable = lib.mkEnableOption "user b";
		hostname = lib.mkOption {
			defaultText = "hostname of the current system";
			type = lib.types.str;
		};
	};

	config = lib.mkIf cfg.enable {
		users.users.b = {
			isNormalUser = true;
			description = "Brennan Seymour";
			extraGroups = [ "networkmanager" "wheel" "wireshark" "docker" ];
			shell = pkgs.zsh;
			packages = with pkgs; [
				vscodium
				vscode
				zed-editor
				neovim
				flatpak
				obsidian
				vlc
				kitty
				spotify
				gimp
				asdf-vm
			];
		};
		fonts.packages = with pkgs; [
			nerd-fonts.comic-shanns-mono
			nerd-fonts.meslo-lg
			nerd-fonts.fira-code
		];
		programs.zsh.enable = true;
		home-manager = {
			users.b = ./home.nix;
			extraSpecialArgs = {
				inherit flake-inputs;
				userConfiguration = cfg;
			};
		};
	};
}
