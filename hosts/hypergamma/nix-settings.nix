{
    config,
    pkgs,
    ...
}: {
    nix.settings = {
        experimental-features = [
            "nix-command"
            "flakes"
        ];

        auto-optimise-store = true;

        # enable additional binary caches
        substituters = [
        "https://nix-gaming.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
        "https://fryuni.cachix.org"
        ];
        trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "fryuni.cachix.org-1:YCNe73zqPG2YLIxxJkTXDz3/VFKcCiZAvHDIjEJIoDQ="
        ];
    };

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };
}