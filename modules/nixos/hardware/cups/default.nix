# INFO: NixOS CUPS module.

{
    config,
    lib,
    ...
}:

with lib; {
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
        };
    };
}
