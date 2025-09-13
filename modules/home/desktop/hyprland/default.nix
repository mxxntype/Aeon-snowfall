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
        inherit (config.aeon) monitors;
    in mkIf enable {
        home = {
            packages = with pkgs; [
                grim
                grimblast
                hyprcursor
                slurp
                swww
                wl-clipboard-rs
            ];

            pointerCursor = {
                enable = true;
                size = 16;
                package = pkgs.bibata-cursors;
                name = "Bibata-Modern-Classic";
            };
        };

        wayland.windowManager.hyprland = {
            enable = true;
            package = if (source == "nixpkgs")
                      then pkgs.hyprland
                      else inputs.hyprland.packages.${pkgs.system}.default;

            settings = let
                MOD = "SUPER";

                notify =
                    message:
                    icon_code:
                    color_code:
                    "${pkgs.hyprland}/bin/hyprctl notify ${toString icon_code} 3000 rgb\\(${color_code}\\) ${message}";

                # Caps to the largest workspace ID from all enabled monitors.
                workspaceCount = let
                    workspaces = monitors
                        |> builtins.filter (monitor: monitor.enable)
                        |> builtins.map (monitor: monitor.workspaces)
                        |> flatten;
                in foldl' max (builtins.head workspaces) (builtins.tail workspaces);
                
                # Caps to the highest refresh rate from all enabled monitors.
                highestRefreshRate = let
                    refreshRates = monitors
                        |> builtins.filter (monitor: monitor.enable)
                        |> builtins.map (monitor: monitor.refreshRate);
                in foldl' max (builtins.head refreshRates) (builtins.tail refreshRates);
            in rec {
                env = [
                    "SWWW_TRANSITION_DURATION, 2"
                    "SWWW_TRANSITION_FPS, ${toString highestRefreshRate}"
                    # "SWWW_TRANSITION, left"

                    # INFO: https://wiki.nixos.org/wiki/Wayland#X_and_Wayland_support
                    # Basically allows electron-based apps to run on a wayland-native backend.
                    "NIXOS_OZONE_WL, 1"

                    "HYPRCURSOR_THEME, ${toString config.home.pointerCursor.name}"
                    "HYPRCURSOR_SIZE, ${toString config.home.pointerCursor.size}" # BUG: Gets fucking ignored.
                ];

                input = {
                    kb_layout = "us,ru";
                    kb_options = "grp:win_space_toggle";

                    # NOTE (from https://wiki.hyprland.org/0.49.0/Configuring/Variables/#input):
                    # 0 - Cursor movement will not change focus.
                    # 1 - Cursor movement will always change focus to the window under the cursor.
                    # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
                    # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
                    follow_mouse = 1;

                    repeat_rate = 50;
                    repeat_delay = 250;
                };

                monitor = monitors |> builtins.map
                    (monitor: let
                        inherit (monitor)
                            port
                            width
                            height
                            refreshRate
                            offsetX
                            offsetY
                            scale
                            ;
                    in if monitor.enable
                       then "${port}, ${toString width}x${toString height}@${toString refreshRate}, ${toString offsetX}x${toString offsetY}, ${toString scale}"
                       else "${port}, disable");

                workspace = monitors
                    |> builtins.filter (monitor: monitor.enable)
                    |> builtins.map (monitor: monitor.workspaces
                        |> builtins.map (workspace: "${toString workspace}, monitor:${monitor.port}, persistent:true"))
                    |> lib.flatten;

                bind = builtins.concatLists [
                    # General binds.
                    [
                        "${MOD} CTRL SHIFT, E, exit"
                        "${MOD}           , F, fullscreen"
                        "${MOD}           , T, togglefloating"
                        "${MOD}      SHIFT, Q, killactive"
                        "${MOD} CTRL SHIFT, Q, forcekillactive"
                        "${MOD}      SHIFT, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

                        # Screenshotting and other screen manipulations.
                        "                 , Print, exec, ${pkgs.grimblast}/bin/grimblast copy area"
                        "       CTRL      , Print, exec, ${pkgs.grimblast}/bin/grimblast copy screen"
                        "${MOD}      SHIFT, P,     exec, ${pkgs.hyprpicker}/bin/hyprpicker --autocopy"
                    ]

                    # Applications.
                    [
                        "${MOD}    , RETURN, exec, ${pkgs.alacritty}/bin/alacritty"
                        "CTRL SHIFT, 2,      exec, ${if config.aeon.apps.gimp.enable then "gimp" else (notify "GIMP is not enabled" 3 "${ui.error}")}"
                        "CTRL SHIFT, 3,      exec, ${pkgs.firefox}/bin/firefox"
                        "CTRL SHIFT, 4,      exec, ${pkgs.telegram-desktop}/bin/telegram-desktop"
                        "CTRL SHIFT, 6,      exec, ${pkgs.virt-manager}/bin/virt-manager"
                        "CTRL SHIFT, 7,      exec, ${pkgs.prismlauncher}/bin/prismlauncher"
                        "CTRL SHIFT, 8,      exec, ${pkgs.keepassxc}/bin/keepassxc"
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

                exec = [
                    "${pkgs.hyprland}/bin/hyprctl setcursor ${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}"
                    "sleep 0.5 && ${pkgs.swww}/bin/swww img ~/.wallpaper"
                ];

                general = {
                    border_size = 2;
                    "col.active_border" = "rgb(${ui.bg.overlay0})";
                    "col.inactive_border" = "rgb(${ui.bg.surface0})";
                };

                bezier = [
                    "cubic, 0.65, 0, 0.35, 1"
                    "sine, 0.37, 0, 0.63, 1"
                    "quad, 0.45, 0, 0.55, 1"
                    "expo, 0.22, 1, 0.36, 1"
                ];

                animations = {
                    enabled = true;
                    first_launch_animation = false;
                };

                animation = [
                    # NAME       ONOFF  SPEED  CURVE   STYLE(opt)
                    "windows,    1,     3,     expo,   slide"
                    "fade,       1,     3,     expo         "
                    "workspaces, 1,     4,     expo,   slide"
                    "border,     1,     8,     default      "
                ];

                windowrule = let
                    gapsOut = 20;
                    rsensor = {
                        width = 640;
                        height = 384;
                    };
                    offsets = {
                        x = rsensor.width + gapsOut + general.border_size * 2;
                        y = gapsOut + general.border_size * 2;
                    };
                in [
                    "float,                                                     title:^(rsensor)$"
                    "size ${toString rsensor.width} ${toString rsensor.height}, title:^(rsensor)$"
                    "move 100%-${toString offsets.x} ${toString offsets.y},     title:^(rsensor)$"
                    "bordercolor rgb(${colors.peach}),                          title:^(rsensor)$"
                ];
            };

            plugins = if (source == "nixpkgs") then [
                pkgs.hyprlandPlugins.hy3
                pkgs.hyprlandPlugins.borders-plus-plus
            ] else [
                inputs.hyprland-hy3.packages.${pkgs.system}.hy3
                inputs.hyprland-plugins.packages.${pkgs.system}.borders-plus-plus
            ];
        };

        programs.hyprlock = {
            enable = true;
            settings = let
                font = "BigBlueTermPlus Nerd Font";
            in {
                general = {
                    hide_cursor = true;
                    ignore_empty_input = true;
                };

                animations = {
                    enabled = true;
                    bezier = [ "expo, 0.22, 1, 0.36, 1" ];
                    animation = [
                        "fadeIn, 1, 5, expo" 
                        "fadeOut, 1, 5, expo" 
                        "inputFieldDots, 1, 2, expo"
                    ];
                };

                background = {
                    monitor = "";
                    path = "/home/${lib.aeon.user}/.wallpaper";
                    blur_passes = 0;
                };

                input-field = {
                    monitor = "";
                    size = "16%, 4%";
                    outline_thickness = 2;
                    inner_color = "rgb(${ui.bg.base})";

                    outer_color = "rgb(${ui.accent})";
                    check_color = "rgb(${ui.warn})";
                    fail_color = "rgb(${ui.error})";

                    font_color = "rgb(${ui.fg.text})";
                    fade_on_empty = true;
                    rounding = 0;

                    font_family = "${font}";
                    placeholder_text = "󱕁 _";
                    fail_text = "<b>[!]</b> 401-DEMONIC-INTERVENTION";

                    dots_text_format = "*";
                    dots_size = 0.4;
                    dots_spacing = 0.3;
                    hide_input = true;

                    position = "0, 0";
                    halign = "center";
                    valign = "center";
                };

                label = [
                    {
                        monitor = "";
                        text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
                        font_size = 90;
                        font_family = "${font}";

                        position = "30, 0";
                        halign = "left";
                        valign = "bottom";
                    }

                    {
                        monitor = "";
                        text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
                        font_size = 25;
                        font_family = "${font}";

                        position = "30, 140";
                        halign = "left";
                        valign = "bottom";
                    }

                    {
                        monitor = "";
                        text = "󰌓 $LAYOUT[EN,RU]";
                        font_size = 64;
                        font_family = "${font}";
                        onclick = "hyprctl switchxkblayout all next";
                        color = "rgb(${ui.fg.text})";

                        position = "-16, 0";
                        halign = "right";
                        valign = "bottom";
                    }

                    # {
                    #     monitor = "";
                    #     text = "subterranean_glass_room";
                    #     font_size = 24;
                    #     font_family = "${font}";

                    #     position = "0, 80";
                    #     halign = "center";
                    #     valign = "center";
                    # }
                ];
            };
        };

        services.hypridle = {
            enable = true;
            settings = {
                general = {
                    lock_cmd = "hyprlock";
                    # unlock_cmd = null;
                    # before_sleep_cmd = null;
                    # after_sleep_cmd = null;
                    
                    ignore_dbus_inhibit = false;
                    ignore_systemd_inhibit = false;
                };

                listener = [
                    {
                        timeout = 300;
                        on-timeout = "hyprlock";
                    }
                    {
                        timeout = 600;
                        on-timeout = "hyprctl dispatch dpms off";
                        on-resume = "hyprctl dispatch dpms on";
                    }
                ];
            };
        };

        services.dunst.enable = true;
    };
}
