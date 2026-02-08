{ config, pkgs, lib, ... }:

{
    options.aeon.wallpapers = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.theme) ui colors;
        cfg = config.aeon.wallpapers;
        colormaps = colors |> lib.attrsToList;

        namecards = lib.aeon.wallpapers.namecards
            |> builtins.map (wallpaper: colormaps |> builtins.map (colormap: wallpaper // { background = colormap; }))
            |> lib.flatten
            |> builtins.map (wallpaper: {
                name = "wallpapers/namecards/${wallpaper.name}-${wallpaper.background.name}.png";
                value.source = let derivation = lib.aeon.generators.wallpapers.dithered-card {
                    inherit pkgs;
                    name = "${wallpaper.name}-${wallpaper.background.name}";
                    source-image = pkgs.fetchurl { inherit (wallpaper) url hash; };
                    border-colors = { inner = ui.bg.surface2; outer = ui.bg.base; };
                    gradient-colors = { start = ui.bg.crust; end = wallpaper.background.value; };
                }; in "${derivation}/output.png";
            });
    in lib.mkIf cfg.enable {
        xdg.configFile =
            [{
                name = "wallpapers/vyrx-dev";
                value.source = pkgs.aeon.wallpapers;
            }]
            ++ namecards
            |> builtins.listToAttrs;
    };
}
