{config, lib, pkgs, inputs, ...}: {

	imports = [
		{
			# apply a special overlay providing a modified godot3
			nixpkgs.overlays = [
        self: super: {
            godot-libxcrypt = super.godot3.overrideAttrs (finalAttrs: previousAttrs: rec {
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
      ]
		}
	];

	environment.systemPackages = [
		pkgs.godot-libxcrypt
	];
}
