_: {
    aeon = rec {
        style.codename = "kanagawa-dragon";

        wallpapers.enable = true;
        desktop.hyprland = {
            enable = true;
            source = "git";
        };
        
        monitors.monitors = [
            {
                name = "KTC H27P22S";  
                port = "DP-2";
                width = 3840;
                height = 2160;
                refreshRate = 160;
                scale = 2.0;
                offsetX = 0;
                offsetY = 0;
                showBar = true;
                workspaces = [ 1 2 3 4 5 6 7 8 9 10 ];
            }
        ];

        apps = {
            gimp.enable = true;
            librewolf.enable = true;
            obsidian.enable = true;
            office.enable = true;
            wezterm.enable = true;
        };

        services.wallpaperengine = {
            enable = true;
            screen = (builtins.head monitors.monitors).port;
            # ID = 2500458873; # "Inazuma Shrine"
            # ID = 3569602312; # "Nod-Krai Columbina Home"
            # ID = 2502719153; # "Seirai"
            # ID = 2459846999; # "Inazuma Castle [Night]"
            # ID = 2570675792; # "Baal"
            # ID = 3572110940; # "Moonfrost"
            # ID = 2745995799; # "Yae"
            # ID = 2970331102; # "Rain Sakura"
            ID = 3237672440; # "Blue, Cherry, Japanese"
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
