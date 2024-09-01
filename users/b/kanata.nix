{config, lib, pkgs, ...}: {
	environment.systemPackages = [
		pkgs.kanata
	];

	services.kanata = {
		enable = true;
		keyboards = {
			"macha".config = ''
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
