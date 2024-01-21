# INFO: Shell Home-manager module.

{
    lib,
    ...
}:

with lib; {
    options.aeon.cli.shell = {
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
