# INFO: Synthing Home-manager module

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.services.syncthing = {
        enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable Syncthing";
        };
    };

    config = mkIf config.aeon.services.syncthing.enable {
        services.syncthing = {
            enable = true;
        };
    };
}
