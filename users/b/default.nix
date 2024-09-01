{config, lib, pkgs, inputs, ...}: {
	imports = [
		# pending https://discourse.nixos.org/t/services-kanata-attribute-lib-missing/51476
		# ./kanata.nix
		inputs.home-manager.nixosModules.default
	];

	options.userconfig.b = {
		enable = lib.mkEnableOption "user b";
	};

	config = {
		users.users.b = {
			isNormalUser = true;
			description = "Brennan Seymour";
			extraGroups = [ "networkmanager" "wheel" ];
			shell = pkgs.zsh;
			packages = with pkgs; [
				vscodium
				zed-editor
				neovim
				gnome-extension-manager
				flatpak
				# discord
				vesktop
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
		home-manager.users.b = ./home.nix;
	};
}
