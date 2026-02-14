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
                name = "Integrated display";  
                port = "eDP-1";
                width = 2880;
                height = 1800;
                refreshRate = 120;
                scale = 1.5;
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
            office.enable = true;
        };

        music.enable = true;
        stylesheets.enable = true;
    };

    home = {
        # WARN: Changing this might break things. Just leave it.
        # The sole legit reason to change this is a reinstallation.
        stateVersion = "25.11";
    };
}
