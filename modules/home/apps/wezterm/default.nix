# INFO: Wezterm, a powerful cross-platform terminal emulator and multiplexer.

{
    config,
    pkgs,
    lib,
    ...
}:

with lib;

{
    options.aeon.apps.wezterm = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable WezTerm";
        };
    };

    config = let
        inherit (config.aeon.apps.wezterm)
            enable
            ;
    in mkIf enable {
        programs.wezterm = {
            inherit enable;
            package = pkgs.aeon.wezterm;
        };
    };
}
