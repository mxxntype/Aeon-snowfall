# INFO: NixOS gaming module.

{
    lib,
    config,
    ...
}:

with lib; {
    options.aeon.gaming = {
        enable = mkOption {
            type = with types; bool;
            default = false;
            description = "Whether to enable gaming support";
        };
    };

    config = let
        inherit (config.aeon.gaming)
            enable
            ;
    in mkIf enable {
        # enable GameMode to optimise performance on demand.
        programs.gamemode = {
            enable = true;
            settings = { };
        };
    };
}
