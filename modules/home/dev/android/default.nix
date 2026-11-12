{ config, lib, pkgs, ... }:

with lib; {
    options.aeon.dev.android.enable = mkOption {
        type = types.bool;
        default = false;
    };

    config = let inherit (config.aeon.dev.android) enable ;
    in mkIf enable {
        home.packages = with pkgs; [ android-studio-full ];
    };
}
