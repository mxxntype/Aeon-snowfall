# INFO: Core NixOS module.

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.core = {
        enable = mkOption {
            description = "Whether to enable core NixOS options";
            type = types.bool;
            default = true;
        };
    };

    config = mkIf config.aeon.core.enable {
        users = {
            mutableUsers = mkDefault false;
            users.root = {
                hashedPasswordFile = config.sops.secrets."passwords/root".path;
            };
        };

        sops.secrets."passwords/root" = {
            sopsFile = ../../../lib/secrets.yaml;
            neededForUsers = true;
        };
    };
}
