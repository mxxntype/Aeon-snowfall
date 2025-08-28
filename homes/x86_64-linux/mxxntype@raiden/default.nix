{ ... }:

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
                port = "DP-2";
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

        apps.alacritty.enable = true;

        music.enable = true;
        scream.enable = true;
    };

    # WARN: Changing this might break things. Just leave it.
    # The sole legit reason to change this is a reinstallation.
    home.stateVersion = "25.05";
}
