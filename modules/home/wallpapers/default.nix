{ config, pkgs, lib, ... }:

{
    options.aeon.wallpapers = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = let
        cfg = config.aeon.wallpapers;
        inherit (config.aeon.theme) ui;
    in lib.mkIf cfg.enable {
        xdg.configFile = lib.aeon.wallpapers.namecards
            |> builtins.map (wallpaper: {
                name = "wallpapers/namecards/${wallpaper.name}.png";
                value.source = let derivation = lib.aeon.generators.wallpapers.fromNamecard {
                    inherit pkgs;
                    inherit (wallpaper) name;
                    source-image = pkgs.fetchurl { inherit (wallpaper) url hash; };
                    border-colors = { inner = ui.bg.surface2; outer = ui.bg.base; };
                    gradient-colors = { start = ui.bg.crust; end = ui.bg.overlay0; };
                }; in "${derivation}/output.png";
            })
            |> builtins.listToAttrs;
    };
}
