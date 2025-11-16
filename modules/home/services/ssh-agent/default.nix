{ config, lib, ... }:

{
    options.aeon.services.ssh-agent = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
    };

    config = lib.mkIf config.aeon.services.ssh-agent.enable {
        services.ssh-agent = {
            enable = true;
        };
    };
}
