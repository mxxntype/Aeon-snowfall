# INFO: User's shell NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    # NOTE: ${aeon.user}'s default shell is a Home-manager option. This makes
    # adjustments to NixOS options based on ${aeon.user}'s Home-manager option.
    config = let
        inherit (config.home-manager.users.${aeon.user}.aeon.cli) shell;
    in mkMerge [
        (mkIf (shell.default == "bash") {
            users.users.${aeon.user}.shell = pkgs.bash;
        })

        (mkIf (shell.default == "zsh") {
            users.users.${aeon.user}.shell = pkgs.zsh;
            programs.zsh.enable = true;
        })

        (mkIf (shell.default == "fish") {
            users.users.${aeon.user}.shell = pkgs.fish;
            programs.fish.enable = true;
        })

        (mkIf (shell.default == "nushell") {
            users.users.${aeon.user}.shell = pkgs.nushellFull;
        })
    ];
}
