_: {
    aeon = {
        style.codename = "dark-plus";

        wallpapers.enable = true;
        desktop.hyprland = {
            enable = true;
            source = "nixpkgs";
        };
        
        monitors.monitors = [
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
            wezterm.enable = true;
            gimp.enable = true;
            librewolf.enable = true;
            freetube.enable = true;
        };

        music.enable = true;
        scream.enable = true;
        stylesheets.enable = true;
    };

    home = {
        # WARN: Changing this might break things. Just leave it.
        # The sole legit reason to change this is a reinstallation.
        stateVersion = "25.05";
    };
}
