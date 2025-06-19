# INFO: Core Nix library, accessible from anywhere in the flake.

{ inputs, lib, ... }:

rec {
    # A no-nixpkgs standard library for the nix language.
    # Mostly used for (de)serialization of stuff.
    nix-std = builtins.attrValues inputs.nix-std.lib;

    # I change my username from time to time, and because some NixOS
    # options inherit from from my Home-manager options, I think
    # it's quite reasonable to have my username declared as a variable.
    user = "mxxntype";

    # I don't store my config in /etc/nixos.
    flakePath = "/home/${user}/Aeon";

    # The name of the persistent volume, so I never mess it up.
    persist = "/persist";

    # SSH (and other?..) public keys, so I also never mess them up. Also,
    # should I make a new private key, this would make it much easier to
    # quickly update the public ones everywhere too.
    pubKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvBw3klXzVq5oTXtS061cfcGEjHWflPZNRBRg48N3w/ astrumaureus@Nox"
    ];

    # Common Nix settings. Lives here because it's shared between NixOS and Home-manager.
    nix = {
        # INFO: Syncs the system's Nix registry and $NIX_PATH with the flake's inputs.
        # Makes sure the configuration and CLI commands all run off of the same inputs.
        registry = inputs |> builtins.mapAttrs (_: flake: { inherit flake; });
        nixPath = inputs |> lib.mapAttrsToList (n: _: "${n}=flake:${n}");

        # INFO: Completely disables Nix channels. May cause some unexpected breakages.
        channel.enable = false;

        settings = {
            allowed-users = [ "@builders" "${user}" ];
            trusted-users = [ "@builders" "${user}" ];

            substituters = [
                "https://cache.nixos.org"
                "https://cuda-maintainers.cachix.org"
                "https://hyprland.cachix.org"
                # "https://wezterm.cachix.org"
            ];
            trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
                "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                # "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
            ];

            warn-dirty = false;
            experimental-features = [
                "nix-command"
                "flakes"
                "pipe-operators"
            ];
            
            # INFO: Disable the use of the flake registry on GitHub.
            # Pretty sure this demands a self-maintained instance of... something, so its disabled for now.
            # flake-registry = "";
        };
    };
}
