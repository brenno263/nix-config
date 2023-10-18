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

	outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, ...} @ inputs: 
		let
			overlay-godot = self: super: {
				godot-libxcrypt = super.godot.overrideAttrs (finalAttrs: previousAttrs: rec {
					buildInputs = previousAttrs.buildInputs ++ [ super.libxcrypt-legacy ];
					installPhase = ''
						mkdir -p "$out/bin"
						cp bin/godot.* $out/bin/godot

						wrapProgram "$out/bin/godot" \
						--set ALSA_PLUGIN_DIR ${super.alsa-plugins}/lib/alsa-lib \
						--set LD_LIBRARY_PATH ${super.libxcrypt-legacy}/lib

						mkdir "$dev"
						cp -r modules/gdnative/include $dev

						mkdir -p "$man/share/man/man6"
						cp misc/dist/linux/godot.6 "$man/share/man/man6/"

						mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
						cp misc/dist/linux/org.godotengine.Godot.desktop "$out/share/applications/"
						cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
						cp icon.png "$out/share/icons/godot.png"
						substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
						--replace "Exec=godot" "Exec=$out/bin/godot"
					'';
				});
			};
		in {
			nixosConfigurations = {
				lucy = nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					specialArgs = inputs;
					modules = [
						({...}: {nixpkgs.overlays = [overlay-godot];})
						nixos-hardware.nixosModules.system76
						./configuration.nix
						./hardware-configuration.nix
						./modules/gnome.nix
						./modules/spotify.nix
						./modules/discord.nix
						({pkgs, ...}: {
							environment.systemPackages = with pkgs; [
								godot-libxcrypt
								gimp
								signal-desktop
								vscodium
								docker
								slack
								steam
								ffmpeg
								obs-studio
								vlc
								nodejs_20
								libxcrypt
								srb2
								nix-index
								toybox
							];

							virtualisation.docker.enable = true;
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
