{
    config,
    lib,
    ...
}:

with lib;

{
    options.aeon.multipass = {
        enable = mkOption {
            type = with types; bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.multipass)
            enable
            ;
    in mkIf enable {
        virtualisation.multipass.enable = true;
    };
}
