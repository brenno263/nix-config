{config, lib, pkgs, pkgs-stable, flake-inputs, ...}: {

	imports = [
		# TODO: undo this later when the fix rolls out
		# Temporarily use the stable packaage - the unstable one is broken rn 😥
		# {
		# 	# disable the unstable module
		# 	disabledModules = [ "services/hardware/kanata.nix" ];
		# 	# swap the system package to the stable one
		# 	nixpkgs.overlays = let
		# 	in [ (self: super: { kanata = pkgs-stable.kanata; }) ];
		# }
		# enable the stable module
		# "${flake-inputs.nixpkgs-stable}/nixos/modules/services/hardware/kanata.nix"
        ];

	# environment.systemPackages = [
	# 	pkgs.kanata
	# ];

	/*
	there's a really sticky bug right now with kanata vs its dependency on uinput.
	https://github.com/NixOS/nixpkgs/issues/317282
	A workaround exists!
	 - disable services.kanata
	 - include this line enabling uinput manually
	 - reboot
	 - re-enable the services.kanata bit
	*/
	hardware.uinput.enable = true;

	# right now this just binds caps to esc
	services.kanata = {
		enable = true;
		keyboards = {
			"matcha".config = ''
			(defsrc
				caps
			)

			(deflayer caps_to_esc
				esc
			)
			'';
		};
	};
}
