# INFO: Nix Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.nix = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.dev.nix)
            enable
            ;
    in mkIf enable {
        home.packages = with pkgs; [
            aeon.statix        # Lints and suggestions for the nix programming language.
            deadnix            # Find and remove unused code in .nix source files.
            nix-output-monitor # Processes output of Nix commands to show helpful and pretty information.
        ];
    };
}
