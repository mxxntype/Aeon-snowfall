# INFO: Hyprland Home-manager module.

{ config, lib, pkgs, inputs, ... }:

with lib; {
    # HACK: Here, because importing in flake.nix does not work.
    imports = with inputs; [ hyprland.homeManagerModules.default ];

    options.aeon.desktop.hyprland = {
        enable = mkOption {
            description = "Whether to enable and configure Hyprland";
            type = with types; bool;
            default = false;
        };

        # NOTE: Using `"nixpkgs"` will make Nix use the Nixpkgs-provided version of Hyprland.
        # Otherwise, Hyprland will come from flake's inputs (see flake.nix). That might cause
        # some extra building from source, however gives more control over versions of stuff.
        source = mkOption {
            type = with types; enum [ "nixpkgs" "git" ];
            default = "git";
        };
    };

    config = let
        inherit (config.aeon.desktop.hyprland)
            enable
            source
            ;
        inherit (config.aeon.theme)
            colors
            ui
            ;
    in mkIf enable {
        home.packages = with pkgs; [ swww ];

        wayland.windowManager.hyprland = {
            enable = true;
            package = if (source == "nixpkgs")
                      then pkgs.hyprland
                      else inputs.hyprland.packages.${pkgs.system}.default;

            settings = let
                MOD = "SUPER";
                workspaceCount = 10;
                
                # HACK: Hardcode due to the lack of the `monitors` module from Aeon.
                hardcodedMonitor = "DP-2";
            in {
                input = {
                    kb_layout = "us,ru";
                    kb_options = "grp:win_space_toggle";

                    # NOTE (from https://wiki.hyprland.org/0.48.0/Configuring/Variables/#input):
                    # 0 - Cursor movement will not change focus.
                    # 1 - Cursor movement will always change focus to the window under the cursor.
                    # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
                    # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
                    follow_mouse = 2;

                    repeat_rate = 50;
                    repeat_delay = 250;
                };

                bind = builtins.concatLists [
                    # General binds.
                    [
                        "${MOD} CTRL SHIFT, E, exit"
                        "${MOD}           , F, fullscreen"
                        "${MOD}      SHIFT, Q, killactive"
                        "${MOD} CTRL SHIFT, Q, forcekillactive"
                    ]

                    # Applications.
                    [
                        "${MOD}    , RETURN, exec, ${pkgs.alacritty}/bin/alacritty"
                        "CTRL SHIFT, 3,      exec, ${pkgs.firefox}/bin/firefox"
                        "CTRL SHIFT, 4,      exec, ${pkgs.telegram-desktop}/bin/telegram-desktop"
                        "CTRL SHIFT, 7,      exec, ${pkgs.prismlauncher}/bin/prismlauncher"
                    ]

                    # Generate bindings for switching or moving active window to a workspace.
                    (workspaceCount
                        |> builtins.genList (_id: let
                            id = _id + 1;
                            key = if (id == 10) then 0 else id;
                            workspace_id = toString id;
                        in [
                            "${MOD},       ${toString key}, workspace,       ${workspace_id}"
                            "${MOD} SHIFT, ${toString key}, movetoworkspace, ${workspace_id}"
                        ])
                        |> builtins.concatLists)
                ];

                bindm = [
                    # Mouse support for grabbing and resizing windows.
                    "${MOD}, mouse:272, movewindow"
                    "${MOD}, mouse:273, resizewindow"
                ];

                exec-once = [
                    "${pkgs.swww}/bin/swww-daemon"
                ];

                # TODO: Figure out why the fuck this is so unreliable.
                exec = [
                    "sleep 1 && ${pkgs.swww}/bin/swww clear ${ui.bg.crust}"
                ];

                # HACK: Hardcode due to the lack of the `monitors` module from Aeon.
                monitor = [
                    "${hardcodedMonitor}, 3840x2160@144, 0x0, 2"
                ];

                general = {
                    border_size = 2;
                    "col.active_border" = "rgb(${colors.red})";
                    "col.inactive_border" = "rgb(${ui.bg.surface0})";
                };
            };

            plugins = if (source == "nixpkgs") then [
                pkgs.hyprlandPlugins.hy3
                pkgs.hyprlandPlugins.borders-plus-plus
            ] else [
                inputs.hyprland-hy3.packages.${pkgs.system}.hy3
                inputs.hyprland-plugins.packages.${pkgs.system}.borders-plus-plus
            ];
        };
    };
}
