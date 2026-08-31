{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.adb = {
        # Whether to enable the Android Debug Bridge.
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf config.aeon.hardware.adb.enable {
        environment.systemPackages = [ pkgs.android-tools ];
        users.users.${lib.aeon.user}.extraGroups = [ "adbusers" ];
    };
}
