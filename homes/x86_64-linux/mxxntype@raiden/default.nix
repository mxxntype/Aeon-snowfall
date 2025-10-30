{ config, lib, ... }:

{
    aeon = {
        style.codename = "kanagawa-wave";

        desktop = {
            hyprland = {
                enable = true;
                source = "nixpkgs";
            };

            quickshell = { enable = true; };
        };

        monitors = [
            {
                name = "KTC H27P22S";  
                port = "DP-1";
                width = 3840;
                height = 2160;
                refreshRate = 144;
                scale = 2.0;
                offsetX = 0;
                offsetY = 0;
                showBar = true;
                workspaces = [ 1 2 3 4 5 6 7 8 9 10 ];
            }
        ];

        apps = {
            alacritty.enable = true;
            gimp.enable = true;
        };

        music.enable = true;
        scream.enable = true;
    };

    home = {
        # WARN: Changing this might break things. Just leave it.
        # The sole legit reason to change this is a reinstallation.
        stateVersion = "25.05";
    };

    xdg.configFile = {
        "stylesheets/docs.rs.less".text =
            lib.aeon.generators.stylesheets.docs-rs {
                theme = config.aeon.theme;
                inherit (config.home) homeDirectory;
            };

        "stylesheets/nixos-search.less".text =
            lib.aeon.generators.stylesheets.nixos-search { inherit (config.aeon) theme; };

        "stylesheets/github.less".text =
            lib.aeon.generators.stylesheets.github { inherit (config.aeon) theme; };

        "stylesheets/stylus.less".text =
            lib.aeon.generators.stylesheets.stylus { inherit (config.aeon) theme; };
    };
}
