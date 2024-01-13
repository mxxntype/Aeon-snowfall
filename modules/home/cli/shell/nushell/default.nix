# INFO: Nushell Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.shell.nushell = {
        enable = mkOption {
            description = "Whether to enable Nushell, a new type of shell";
            type = types.bool;
            default = true;
        };
    };
    
    config = mkIf config.aeon.cli.shell.nushell.enable {
        programs = {
            nushell = {
                enable = true;
                package = pkgs.nushellFull;
                shellAliases = config.aeon.cli.shell.aliases;
            };

            # Multi-shell multi-command argument completer.
            carapace.enable = true;
        };
    };
}
