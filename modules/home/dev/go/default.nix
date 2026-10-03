{ config, lib, pkgs, ... }:

with lib; {
    options.aeon.dev.go = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.dev.go)
            enable
            ;
    in mkIf enable {
        programs.go = {
            enable = true;
            telemetry.mode = "off";
        };
        home.packages = with pkgs; [ gopls ];
    };
}
