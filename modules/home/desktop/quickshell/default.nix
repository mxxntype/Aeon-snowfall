{ inputs, config, pkgs, lib, ... }: with lib;

{
    options.aeon.desktop.quickshell = with types; {
        enable = mkOption {
            type = bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.desktop.quickshell)
            enable
            ;
    in mkIf enable {
        home.packages = [
            inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default

            # NOTE: Oh god its KDE.
            # But this is the only sane provider of `qmlls`.
            pkgs.kdePackages.qtdeclarative
        ];
    };
}
