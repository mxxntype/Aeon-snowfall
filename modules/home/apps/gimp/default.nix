{ config, pkgs, lib, ... }:

{
    options.aeon.apps.gimp = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf config.aeon.apps.gimp.enable {
        home.packages = [
            (pkgs.gimp3-with-plugins.override {
                plugins = with pkgs.gimpPlugins; [ gmic ];
            })
        ];
    };
}
