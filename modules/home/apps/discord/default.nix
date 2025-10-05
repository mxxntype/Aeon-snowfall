{ config, lib, pkgs, ... }:

{
    options.aeon.apps.discord = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to enable Discord";
        };

        app = lib.mkOption {
            type = lib.types.enum [ "vencord" ];
            default = "vencord";
            description = "What Discord client to use";
        };
    };

    config = let
        inherit (config.aeon.apps.discord)
            enable
            app
            ;
    in lib.mkIf enable (lib.mkMerge [
        (lib.mkIf (app == "vencord") {
            home.packages = with pkgs; [ vesktop ];
        })
    ]);
}
