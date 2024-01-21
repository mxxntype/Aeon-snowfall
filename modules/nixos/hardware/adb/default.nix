# INFO: NixOS Android Debug Bridge module.

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.hardware.adb = {
        # Wether to enable the Android Debug Bridge.
        enable = mkOption {
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.hardware.adb.enable {
        programs.adb.enable = true;
        users.users.${aeon.user}.extraGroups = [ "adbusers" ];
    };
}
