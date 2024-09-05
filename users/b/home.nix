{ config, pkgs, inputs, userConfiguration, ... }:
{
	# Home Manager needs a bit of information about you and the
	# paths it should manage.
	home.username = "b";
	home.homeDirectory = "/home/b";

	# This value determines the Home Manager release that your
	# configuration is compatible with. This helps avoid breakage
	# when a new Home Manager release introduces backwards
	# incompatible changes.
	#
	# You can update Home Manager without changing this value. See
	# the Home Manager release notes for a list of state version
	# changes in each release.
	home.stateVersion = "23.11";

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	programs.bash.enable = true;
	home.sessionVariables = {
		MANGOHUD_CONFIGFILE =
			"/home/b/.config/mangohud.conf";
	};

	home.file.".config/mangohud.conf".source = ./mangohud.conf;
	home.file.".config/nixpkgs/config.nix".text = ''
	{
		allowUnfree = true;
	}
	'';
	home.file.".config/discord/settings.json".text = ''
	{
		"SKIP_HOST_UPDATE": true
	}
	'';

	programs.git = {
		enable = true;
		userName = "Brennan Seymour";
		userEmail = "brenno263@gmail.com";
		aliases = {
			co = "checkout";
			st = "status";
			br = "branch";
			cm = "commit";
		};
		extraConfig = {
			init.defaultBranch = "main";
		};
	};

	programs.zsh = {
		enable = true;

		oh-my-zsh = {
			enable = true;
			theme = "refined";
		};

		shellAliases = {
			nixswitch = ("sudo nixos-rebuild switch --flake ~/nixos#" + userConfiguration.hostname );
		};
	};

	programs.kitty = {
		enable = true;
		theme = "Apprentice";
		extraConfig = ''
			window_margin_width 4
		'';
	};

	dconf = {
		enable = true;

		# set extensions
		settings."org/gnome/shell" = {
			disable-user-extensions = false;
			enabled-extensions = with pkgs.gnomeExtensions; [
				appindicator.extensionUuid
				blur-my-shell.extensionUuid
			];
		};

		# set dark mode
		settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
	};
}
