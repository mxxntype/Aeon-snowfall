{ lib, config, ... }:

{
    options.aeon.services.wallpaperengine = {
        enable = lib.mkEnableOption "Linux-wallpaperengine";
        screen = lib.mkOption { type = lib.types.str; };
        ID     = lib.mkOption { type = lib.types.int; };
    };

    config = let
        inherit (config.aeon.services.wallpaperengine)
            enable
            screen
            ID
            ;
    in lib.mkIf enable {
        services.linux-wallpaperengine = {
            enable = true;
            wallpapers = [ {
                monitor = screen;
                wallpaperId = toString ID;
            } ];

            audio.silent = true;
        };
    };
}
