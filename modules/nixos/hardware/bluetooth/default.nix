# INFO: NixOS Bluetooth module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.hardware.bluetooth = {
        # Whether to enable bluetooth support.
        enable = mkOption {
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.hardware.bluetooth.enable {
        hardware.bluetooth.enable = true;
        services.blueman.enable = true;
        environment.systemPackages = with pkgs; [ aeon.bluetui ];
    };
}
