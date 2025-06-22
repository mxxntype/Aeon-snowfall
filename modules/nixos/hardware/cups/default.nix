# INFO: NixOS CUPS module.

{ config, pkgs, lib, ... }: with lib;

{
    options.aeon.hardware.cups = {
        # Whether to enable the CUPS printing service.
        enable = mkOption {
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.hardware.cups.enable {
        services.printing = {
            enable = true;
            drivers = with pkgs; [ hplipWithPlugin ];

            # WARN: The autodiscovery thing of CUPS is sorta
            # a security nightmare, so stay away from that.
            browsed.enable = false;
        };
    };
}
