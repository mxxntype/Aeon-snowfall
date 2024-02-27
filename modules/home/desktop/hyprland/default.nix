# INFO: Hyprland Home-manager module.

{
    config,
    lib,
    inputs,
    ...
}:

with lib; {
    # HACK: Here, because importing in flake.nix does not work.
    imports = with inputs; [ hyprland.homeManagerModules.default ];

    options.aeon.desktop.hyprland = {
        enable = mkOption {
            description = "Whether to enable and configure Hyprland";
            type = with types; bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.desktop.hyprland)
            enable
            ;
    in (mkIf enable {
        wayland.windowManager.hyprland = {
            enable = true;
            settings = let
                MOD = "SUPER";
            in {
                bind = [
                    "${MOD} CTRL SHIFT, exit"
                ]
                ++ builtins.concatLists (builtins.genList (ws: [
                    # Switch or move active window to a workspace.
                    "${MOD},       ${toString ws}, workspace, ${toString (ws + 1)}"
                    "${MOD} SHIFT, ${toString ws}, movetoworkspace, ${toString (ws + 1)}"
                ]) 10);
            };
        };
    });
}
