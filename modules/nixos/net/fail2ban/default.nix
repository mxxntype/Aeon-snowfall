{
    config,
    lib,
    ...
}:

with lib;

{
    options.aeon.net.fail2ban = {
        enable = mkOption {
            type = with types; bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.net.fail2ban)
            enable
            ;
    in mkIf enable {
        services.fail2ban = {
            enable = true;
        };
    };
}
