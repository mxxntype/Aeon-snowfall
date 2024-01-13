# INFO: Shell Home-manager module.

{
    lib,
    ...
}:

with lib; {
    options.aeon.cli.shell = {
        aliases = mkOption {
            description = "Shell aliases";
            type = types.attrs;
            default = {
                lsa = "ls -a";
                cat = "bat";
                btm = "btm --battery";
                ip = "ip --color=always";
                tree = "erd --config tree";
                sz = "erd --config sz";
                duf = "duf -theme ansi";
            };
        };

        default = mkOption {
            description = "Which shell to use as default";
            type = types.enum [
                # "bash" # TODO: Implement shell/<shell>.nix modules.
                # "zsh"
                # "fish"
                "nushell"
            ];
            default = "nushell";
        };
    };
}
