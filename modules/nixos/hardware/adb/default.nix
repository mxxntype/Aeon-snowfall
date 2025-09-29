{ config, lib, ... }:

{
    options.aeon.hardware.adb = {
        # Whether to enable the Android Debug Bridge.
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf config.aeon.hardware.adb.enable {
        programs.adb.enable = true;
        users.users.${lib.aeon.user}.extraGroups = [ "adbusers" ];
    };
}
