# INFO: Hyprland Home-manager module.

{
    config,
    lib,
    pkgs,
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
    in mkIf enable {
        wayland.windowManager.hyprland = {
            enable = true;
            package = pkgs.hyprland;
            settings = let
                MOD = "SUPER";
            in {
                bind = builtins.concatLists [
                    # General binds.
                    [
                        "${MOD} CTRL SHIFT, E, exit"
                    ]

                    # Generate bindings for switching or moving active window to a workspace.
                    (builtins.concatLists (builtins.genList (_ws: 
                        let ws = toString (_ws + 1); in [
                            "${MOD},       ${ws}, workspace,       ${ws}"
                            "${MOD} SHIFT, ${ws}, movetoworkspace, ${ws}"
                        ])
                        /* WORKSPACE_COUNT: */ 10))
                ];

                exec-once = [
                    "${pkgs.kitty}/bin/kitty"
                ];
            };

            plugins = with pkgs.hyprlandPlugins; [
                borders-plus-plus # Double borders for the looks.
                hy3               # i3-like manual tiling layout.
            ];
        };
    };
}
