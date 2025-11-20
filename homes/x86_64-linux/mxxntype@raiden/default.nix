{ lib, pkgs, config, ... }:

{
    aeon = {
        style.codename = "dark-plus";

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
            gimp.enable = true;
            wezterm.enable = true;
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

    xdg.configFile."wallpapers/namecard.png".source = let
        inherit (config.aeon.theme) ui;
        source-image = pkgs.fetchurl {
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/9/9d/Namecard_Background_Achievement_Infinitum.png/revision/latest?cb=20230412034747";
            # hash = "sha256-jMQxPdsQ9yBLU7VQ6pQ7nIuwcFe5X+8KKkUQ2GW1CEg=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/f/f8/Namecard_Background_Travel_Notes_Woodlands.png/revision/latest?cb=20220826151244";
            # hash = "sha256-gkPwxr7lptBqn2+n8KxbPoQt3k3oxB6B3/VyMm1UDxE=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/1/17/Namecard_Background_Inazuma_Kujou_Insignia.png/revision/latest?cb=20210725071326";
            # hash = "sha256-PgLuAV4Ne/6GpaiMdF40lBaSm7N9K63RLuTOiamkRE4=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/4/4c/Namecard_Background_Inazuma_Eagleplume.png/revision/latest?cb=20211013104446";
            # hash = "sha256-R+5tGwnYXogq0rzrhf0IuO9KMyXWyRap1NCTzE+8mW0=";
            url = "https://static.wikia.nocookie.net/gensin-impact/images/5/5e/Namecard_Background_Raiden_Shogun_Enlightenment.png/revision/latest?cb=20210902035057";
            hash = "sha256-H8pwdxjeWbnb270Ic656rJHZMxqM7GPyzqVWQYRo1JQ=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/8/8b/Namecard_Background_Achievement_Fighting_Spirit.png/revision/latest?cb=20241129014713";
            # hash = "sha256-3Q5SEgRKbGTCoy1B+GMC2seC3emr8C22i18G/16ryL0=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/e/e9/Namecard_Background_Sumeru_Sandstorm.png/revision/latest?cb=20230118035112";
            # hash = "sha256-wixXEN/zhgspD9RMjj2ozc7FFPbXoclHa/vMvgpUHcM=";
            # url = "https://static.wikia.nocookie.net/gensin-impact/images/e/ef/Namecard_Background_Travel_Notes_Irodori.png/revision/latest?cb=20220330033749";
            # hash = "sha256-mOTQJcYa0G2VfJfHWsg7Cs+6nfd5gxpDrqYtGseQmj4=";
            # url = "https://raw.githubusercontent.com/mxxntype/wallpapers/main/random/drift.webp";
            # hash = "sha256-Joozg54DbSpxn3WZaD+HiM1Ts6YjvQrJQLsFQmw62TU=";
        };
        derivation = lib.aeon.fromNamecard {
            inherit pkgs source-image;
            border-colors = { inner = ui.bg.surface2; outer = ui.bg.base; };
            gradient-colors = { start = ui.bg.crust; end = ui.bg.overlay0; };
        };
    in "${derivation}/output.png";
}
