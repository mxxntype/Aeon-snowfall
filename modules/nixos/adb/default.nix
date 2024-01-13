# INFO: ADB NixOS module.

{
    lib,
    config,
    ...
}:

with lib; {
    options.aeon.adb = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable ADB";
        };
    };

    config = mkIf config.aeon.adb.enable {
        programs.adb.enable = true;
        users.users.${aeon.user}.extraGroups = [ "adbusers" ];
    };
}
