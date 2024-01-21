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
                shellAliases = {
                    lsa = "ls -a";
                    cat = "${pkgs.bat}/bin/bat";
                    btm = "${pkgs.bottom}/bin/btm --battery";
                    ip = "ip --color=always";
                    duf = "${pkgs.duf}/bin/duf -theme ansi";
                    # tree = "erd --config tree";
                    # sz = "erd --config sz";
                };

                envFile.text = /* nu */ ''
                    $env.LS_COLORS = "${config.aeon.theme.cli.ls}"
                '';
            };

            # TODO: Multi-shell multi-command argument completer.
            # carapace.enable = true;
        };
    };
}
