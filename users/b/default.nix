{config, lib, pkgs, inputs, ...}:
let
	cfg = config.userconfig.b;
in {

	imports = [
		# pending https://discourse.nixos.org/t/services-kanata-attribute-lib-missing/51476
		./kanata.nix
		inputs.home-manager.nixosModules.default
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
			extraGroups = [ "networkmanager" "wheel" ];
			shell = pkgs.zsh;
			packages = with pkgs; [
				vscodium
				zed-editor
				neovim
				flatpak
				# discord is kinda borked right now for wayland. Just use it in browser for now
				discord
				vlc
				kitty
				spotify
				gimp
				asdf-vm
			];
		};
		fonts.packages = with pkgs; [
			(nerdfonts.override {fonts = [
				"ComicShannsMono"
				"Meslo"
				"FiraCode"
			];})
		];
		programs.zsh.enable = true;
		home-manager = {
			users.b = ./home.nix;
			extraSpecialArgs = {
				inherit inputs;
				userConfiguration = cfg;
			};
		};
	};
}
