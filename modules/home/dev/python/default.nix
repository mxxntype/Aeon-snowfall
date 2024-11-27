# INFO: Python Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.python = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.dev.python)
            enable
            ;
    in mkIf enable {
        home.packages = with pkgs; [
            # Python itself.
            (python311.withPackages (ps: with ps; [
                python-lsp-server
            ]))

            # LSP servers, formatters and linters
            black
            pyright
            ruff
            ruff-lsp

            # An extremely fast Python package installer and resolver, written in Rust.
            # (A replacement for pip, which does not work as expected on NixOS)
            uv
        ];
    };
}
