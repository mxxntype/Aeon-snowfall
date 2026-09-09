{ config, lib, ... }:

{
    options.aeon.apps.discord = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to enable Discord";
        };

        app = lib.mkOption {
            type = lib.types.enum [ "vesktop" ];
            default = "vesktop";
            description = "What Discord client to use";
        };
    };

    config = let
        inherit (config.aeon.apps.discord)
            enable
            app
            ;
    in lib.mkIf enable (lib.mkMerge [
        (lib.mkIf (app == "vesktop") {
            programs.vesktop.enable = true;
        })
    ]);
}
