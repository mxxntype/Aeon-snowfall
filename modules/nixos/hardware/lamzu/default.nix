{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.lamzu = {
        udev-rules.enable = lib.mkEnableOption "udev rules for LAMZU peripherals";
    };

    config = let cfg = config.aeon.hardware.lamzu;
    in lib.mkIf cfg.udev-rules.enable {
        services.udev.packages = [ pkgs.aeon.lamzu ];
    };
}
