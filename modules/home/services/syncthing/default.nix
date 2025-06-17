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

        # INFO: Syncthing creates a `Sync` folder in your home directory when it
        # regenerates a configuration, even if your declarative configuration
        # does not have this folder. Lets fix that.
        systemd.user.services.syncthing.Service.Environment = [ "STNODEFAULTFOLDER=true" ];
    };
}
