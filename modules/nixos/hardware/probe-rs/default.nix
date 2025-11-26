{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.probe-rs = {
        udev-rules.enable = lib.mkEnableOption "udev rules for `probe-rs`";
    };

    config = let cfg = config.aeon.hardware.probe-rs;
    in lib.mkIf cfg.udev-rules.enable {
        users.groups.plugdev = { };
        services.udev.packages = [ pkgs.aeon.probe-rs ];
    };
}
