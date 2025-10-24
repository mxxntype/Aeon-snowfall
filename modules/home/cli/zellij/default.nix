{ config, inputs, pkgs, lib, ... }:

{
    options.aeon.cli.zellij = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.cli.zellij) enable;
        inherit (config.aeon.theme) colors ui;
        
        defaultTabTemplate = /* kdl */ ''
            default_tab_template {
                children

                floating_panes {
                    pane command="test" close_on_exit=true {
                        x 0
                        y "50%"
                        width "100%"
                        height "50%"
                    }
                }

                pane size=2 borderless=true {
                    plugin location="file:${inputs.zjstatus.packages.${pkgs.system}.default}/bin/zjstatus.wasm" {
                        format_left "${builtins.concatStringsSep "" [
                            "{mode}" 
                            "#[bg=${ui.bg.base}] "
                            "#[fg=#${colors.green},bg=#${ui.bg.surface1},bold] CPU "
                            "#[fg=#${colors.green},bg=#${ui.bg.surface0}] ⣤⣾⣿⣴⣀ "
                            "#[bg=${ui.bg.base}] "
                            "#[fg=#${colors.teal},bg=#${ui.bg.surface1},bold] 󰈁 "
                            "#[fg=#${colors.teal},bg=#${ui.bg.surface0}] ⣴⣤⣿⣤⣀ "
                            "#[fg=#${ui.bg.surface2},bg=#${ui.bg.surface0}]|"
                            "#[fg=#${colors.teal},bg=#${ui.bg.surface0}] 119MB/s "
                        ]}"

                        format_right "${builtins.concatStringsSep "" [
                            "#[fg=#${colors.lavender},bg=#${ui.bg.surface1},bold]   "
                            "#[fg=#${colors.lavender},bg=#${ui.bg.surface0}] 37% "
                            "#[bg=${ui.bg.base}] "
                            "#[fg=#${ui.fg.subtext1},bg=#${ui.bg.surface0}] {datetime} "
                            "#[fg=#${colors.blue},bg=#${ui.bg.surface1},bold]   #[fg=#${ui.bg.crust},bg=#${colors.blue}]|"
                        ]}"

                        format_center "${builtins.concatStringsSep "" [
                            "{tabs}"
                        ]}"

                        format_space ""

                        border_enabled  "true"
                        border_char     "━"
                        border_format   "#[fg=#${colors.surface2}]{char}"
                        border_position "top"

                        // NOTE: `false` means follow core config, `true`
                        // will turn on frames when a second pane is open.
                        hide_frame_for_single_pane "false"

                        mode_normal  "#[fg=#${colors.crust},bg=#${colors.subtext0},bold] 󰳨 NORMAL "
                        mode_locked  "#[fg=#${colors.crust},bg=#${colors.red     },bold] 󰔌 LOCKED "
                        mode_resize  "#[fg=#${colors.crust},bg=#${colors.green   },bold] 󰊓 RESIZE "
                        mode_pane    "#[fg=#${colors.crust},bg=#${colors.blue    },bold] 󰖲  PANE  "
                        mode_tab     "#[fg=#${colors.crust},bg=#${colors.yellow  },bold] 󰓩  TAB   "
                        mode_scroll  "#[fg=#${colors.crust},bg=#${colors.teal    },bold] 󰮾 SCROLL "
                        mode_session "#[fg=#${colors.crust},bg=#${colors.maroon  },bold] 󰙅  SESH  "
                        mode_move    "#[fg=#${colors.crust},bg=#${colors.mauve   },bold] 󰮴  MOVE  "
                        mode_tmux    "#[fg=#${colors.crust},bg=#${colors.green   },bold] 󰬛  TMUX  "

                        tab_active  " #[bg=#${colors.mauve}] #[fg=#${colors.text},bg=#${colors.surface0},bold] {name} "
                        tab_normal  " #[bg=#${colors.subtext0}] #[fg=#${colors.subtext1},bg=#${colors.surface0}] {name} "

                        command_git_branch_command  "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format   "#[fg=red] {stdout} "
                        command_git_branch_interval  "10"

                        datetime          "{format}"
                        datetime_format   "%A, %d %b %Y %H:%M"
                        datetime_timezone "Europe/Moscow"
                    }
                }
            }
        '';

        layoutDir = "${config.xdg.configHome}/zellij/layouts/";
        defaultLayoutName = "current";

        defaultLayoutVariants = let
            defaultTabSet = /* kdl */ ''
                tab name="󰎇" {
                    pane command="rmpc"
                }
                tab name="󰙅 CLI" focus=true {
                    pane
                }
            '';
        in {
            default = /* kdl */ ''
                layout {
                    ${defaultTabTemplate}
                    ${defaultTabSet}
                }
            '';

            work = /* kdl */ ''
                layout {
                    ${defaultTabTemplate}
                    ${defaultTabSet}
                    tab name="󱕁  Rsensor" cwd="~/Work/rsensor" {
                        pane
                    }
                }
            '';
        };
    in lib.mkIf enable {
        programs.zellij = {
            enable = true;
            package = pkgs.zellij;
        };

        xdg.configFile."zellij/config.kdl".text = /* kdl */ ''
            layout_dir "${config.xdg.configHome}/zellij/layouts/"
            default_layout "${defaultLayoutName}"
            pane_frames false

            theme "nix"
            themes {
                nix {
                    fg "#${colors.surface2}"
                    bg "#${colors.surface0}"
                    black "#${colors.base}"
                    white "#${colors.text}"

                    red "#${colors.green}"
                    orange "#${colors.maroon}"
                    yellow "#${colors.peach}"
                    green "#${colors.mauve}"
                    blue "#${colors.blue}"
                    cyan "#${colors.teal}"
                    magenta "#${colors.red}"
                }
            }

            ui {
                pane_frames {
                    rounded_corners false
                    hide_session_name true
                }
            }
    
            // If you'd like to override the default keybindings completely, be sure to change "keybinds" to "keybinds clear-defaults=true"
            keybinds {
                normal {
                    // uncomment this and adjust key if using copy_on_select=false
                    // bind "Alt c" { Copy; }

                    unbind "Alt h" "Alt j" "Alt k" "Alt l" "Alt f"
                    bind "Alt H" { MoveFocus "Left"; }
                    bind "Alt J" { MoveFocus "Down"; }
                    bind "Alt K" { MoveFocus "Up"; }
                    bind "Alt L" { MoveFocus "Right"; }

                    bind "Alt ." { GoToNextTab; }
                    bind "Alt ," { GoToPreviousTab; }

                    bind "Alt i" { ToggleFloatingPanes; }
                }

                locked {
                    bind "Ctrl g" { SwitchToMode "Normal"; }
                }

                resize {
                    bind "Ctrl n" { SwitchToMode "Normal"; }
                    bind "h" "Left" { Resize "Increase Left"; }
                    bind "j" "Down" { Resize "Increase Down"; }
                    bind "k" "Up" { Resize "Increase Up"; }
                    bind "l" "Right" { Resize "Increase Right"; }
                    bind "H" { Resize "Decrease Left"; }
                    bind "J" { Resize "Decrease Down"; }
                    bind "K" { Resize "Decrease Up"; }
                    bind "L" { Resize "Decrease Right"; }
                    bind "=" "+" { Resize "Increase"; }
                    bind "-" { Resize "Decrease"; }
                }
                pane {
                    bind "Ctrl p" { SwitchToMode "Normal"; }
                    bind "h" "Left" { MoveFocus "Left"; }
                    bind "l" "Right" { MoveFocus "Right"; }
                    bind "j" "Down" { MoveFocus "Down"; }
                    bind "k" "Up" { MoveFocus "Up"; }
                    bind "p" { SwitchFocus; }
                    bind "n" { NewPane; SwitchToMode "Normal"; }
                    bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                    bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
                    bind "x" { CloseFocus; SwitchToMode "Normal"; }
                    bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                    bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
                    bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                    bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                    bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0;}
                }
                move {
                    bind "Ctrl h" { SwitchToMode "Normal"; }
                    bind "n" "Tab" { MovePane; }
                    bind "p" { MovePaneBackwards; }
                    bind "h" "Left" { MovePane "Left"; }
                    bind "j" "Down" { MovePane "Down"; }
                    bind "k" "Up" { MovePane "Up"; }
                    bind "l" "Right" { MovePane "Right"; }
                }
                tab {
                    bind "Ctrl t" { SwitchToMode "Normal"; }
                    bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                    bind "h" "Left" "Up" "k" { GoToPreviousTab; }
                    bind "l" "Right" "Down" "j" { GoToNextTab; }
                    bind "n" { NewTab; SwitchToMode "Normal"; }
                    bind "x" { CloseTab; SwitchToMode "Normal"; }
                    bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                    bind "b" { BreakPane; SwitchToMode "Normal"; }
                    bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                    bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
                    bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                    bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                    bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                    bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                    bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                    bind "6" { GoToTab 6; SwitchToMode "Normal"; }
                    bind "7" { GoToTab 7; SwitchToMode "Normal"; }
                    bind "8" { GoToTab 8; SwitchToMode "Normal"; }
                    bind "9" { GoToTab 9; SwitchToMode "Normal"; }
                    bind "Tab" { ToggleTab; }
                }
                scroll {
                    bind "Ctrl s" { SwitchToMode "Normal"; }
                    bind "e" { EditScrollback; SwitchToMode "Normal"; }
                    bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                    bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "j" "Down" { ScrollDown; }
                    bind "k" "Up" { ScrollUp; }
                    bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                    bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                    bind "d" { HalfPageScrollDown; }
                    bind "u" { HalfPageScrollUp; }
                    // uncomment this and adjust key if using copy_on_select=false
                    // bind "Alt c" { Copy; }
                }
                search {
                    bind "Ctrl s" { SwitchToMode "Normal"; }
                    bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "j" "Down" { ScrollDown; }
                    bind "k" "Up" { ScrollUp; }
                    bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                    bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                    bind "d" { HalfPageScrollDown; }
                    bind "u" { HalfPageScrollUp; }
                    bind "n" { Search "down"; }
                    bind "p" { Search "up"; }
                    bind "c" { SearchToggleOption "CaseSensitivity"; }
                    bind "w" { SearchToggleOption "Wrap"; }
                    bind "o" { SearchToggleOption "WholeWord"; }
                }
                entersearch {
                    bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
                    bind "Enter" { SwitchToMode "Search"; }
                }
                renametab {
                    bind "Ctrl c" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
                }
                renamepane {
                    bind "Ctrl c" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
                }
                session {
                    bind "Ctrl o" { SwitchToMode "Normal"; }
                    bind "Ctrl s" { SwitchToMode "Scroll"; }
                    bind "d" { Detach; }
                    bind "w" {
                        LaunchOrFocusPlugin "zellij:session-manager" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                }
                tmux {
                    bind "[" { SwitchToMode "Scroll"; }
                    bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
                    bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
                    bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
                    bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                    bind "c" { NewTab; SwitchToMode "Normal"; }
                    bind "," { SwitchToMode "RenameTab"; }
                    bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
                    bind "n" { GoToNextTab; SwitchToMode "Normal"; }
                    bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
                    bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
                    bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
                    bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
                    bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
                    bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
                    bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
                    bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
                    bind "o" { FocusNextPane; }
                    bind "d" { Detach; }
                    bind "Space" { NextSwapLayout; }
                    bind "x" { CloseFocus; SwitchToMode "Normal"; }
                }
                shared_except "locked" {
                    bind "Ctrl g" { SwitchToMode "Locked"; }
                    bind "Ctrl q" { Quit; }
                    bind "Alt n" { NewPane; }
                    bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
                    bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
                    bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                    bind "Alt k" "Alt Up" { MoveFocus "Up"; }
                    bind "Alt =" "Alt +" { Resize "Increase"; }
                    bind "Alt -" { Resize "Decrease"; }
                    bind "Alt [" { PreviousSwapLayout; }
                    bind "Alt ]" { NextSwapLayout; }
                }
                shared_except "normal" "locked" {
                    bind "Enter" "Esc" { SwitchToMode "Normal"; }
                }
                shared_except "pane" "locked" {
                    bind "Ctrl p" { SwitchToMode "Pane"; }
                }
                shared_except "resize" "locked" {
                    bind "Ctrl n" { SwitchToMode "Resize"; }
                }
                shared_except "scroll" "locked" {
                    bind "Ctrl s" { SwitchToMode "Scroll"; }
                }
                shared_except "session" "locked" {
                    bind "Ctrl o" { SwitchToMode "Session"; }
                }
                shared_except "tab" "locked" {
                    bind "Ctrl t" { SwitchToMode "Tab"; }
                }
                shared_except "move" "locked" {
                    bind "Ctrl h" { SwitchToMode "Move"; }
                }
                shared_except "tmux" "locked" {
                    bind "Ctrl b" { SwitchToMode "Tmux"; }
                }
            }

            plugins {
                tab-bar { path "tab-bar"; }
                status-bar { path "status-bar"; }
                strider { path "strider"; }
                compact-bar { path "compact-bar"; }
                session-manager { path "session-manager"; }
            }

            // Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
            // eg. when terminal window with an active zellij session is closed
            // Options:
            //   - detach (Default)
            //   - quit
            //
            // on_force_close "quit"

            //  Send a request for a simplified ui (without arrow fonts) to plugins
            //  Options:
            //    - true
            //    - false (Default)
            //
            // simplified_ui true

            // Choose the path to the default shell that zellij will use for opening new panes
            // Default: $SHELL
            //
            // default_shell "fish"

            // Choose the path to override cwd that zellij will use for opening new panes
            //
            // default_cwd ""

            // Toggle between having pane frames around the panes
            // Options:
            //   - true (default)
            //   - false
            //
            pane_frames false

            // Toggle between having Zellij lay out panes according to a predefined set of layouts whenever possible
            // Options:
            //   - true (default)
            //   - false
            //
            // auto_layout true

            // Choose the mode that zellij uses when starting up.
            // Default: normal
            //
            // default_mode "locked"

            // Toggle enabling the mouse mode.
            // On certain configurations, or terminals this could
            // potentially interfere with copying text.
            // Options:
            //   - true (default)
            //   - false
            //
            // mouse_mode false

            // Configure the scroll back buffer size
            // This is the number of lines zellij stores for each pane in the scroll back
            // buffer. Excess number of lines are discarded in a FIFO fashion.
            // Valid values: positive integers
            // Default value: 10000
            //
            // scroll_buffer_size 10000

            // Provide a command to execute when copying text. The text will be piped to
            // the stdin of the program to perform the copy. This can be used with
            // terminal emulators which do not support the OSC 52 ANSI control sequence
            // that will be used by default if this option is not set.
            // Examples:
            //
            // copy_command "xclip -selection clipboard" // x11
            // copy_command "wl-copy"                    // wayland
            // copy_command "pbcopy"                     // osx

            // Choose the destination for copied text
            // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
            // Does not apply when using copy_command.
            // Options:
            //   - system (default)
            //   - primary
            //
            // copy_clipboard "primary"

            // Enable or disable automatic copy (and clear) of selection when releasing mouse
            // Default: true
            //
            // copy_on_select false

            // Path to the default editor to use to edit pane scrollbuffer
            // Default: $EDITOR or $VISUAL
            //
            // scrollback_editor "/usr/bin/vim"

            // When attaching to an existing session with other users,
            // should the session be mirrored (true)
            // or should each user have their own cursor (false)
            // Default: false
            //
            // mirror_session true

            // The folder in which Zellij will look for layouts
            //
            // layout_dir "/path/to/my/layout_dir"

            // The folder in which Zellij will look for themes
            //
            // theme_dir "/path/to/my/theme_dir"
        '';

        xdg.configFile."${layoutDir}/default.kdl".text = defaultLayoutVariants.default;
        xdg.configFile."${layoutDir}/default-work.kdl".text = defaultLayoutVariants.work;

        systemd.user = let
            layoutSetupScript = pkgs.nuenv.writeScriptBin {
                name = "zellij-layout-setup.nu";
                script = /* nu */ ''
                    let is_weekend = (date now | format date "%u" | into int) > 5;
                    let is_morning = (date now | format date "%H" | into int) < 8;
                    let is_evening = (date now | format date "%H" | into int) >= 18;
                    if $is_weekend or $is_morning or $is_evening {
                        ${pkgs.coreutils}/bin/ln -sf "${layoutDir}/default.kdl" "${layoutDir}/${defaultLayoutName}.kdl" 
                    } else {
                        ${pkgs.coreutils}/bin/ln -sf "${layoutDir}/default-work.kdl" "${layoutDir}/${defaultLayoutName}.kdl" 
                    }
                '';
            };
        in {
            services.zellij-layout-setup = {
                Unit = { After = [ "graphical-session.target" ]; };
                Install.WantedBy = [ "default.target" ];
                Service = {
                    Type = "oneshot";
                    ExecStart = "${lib.getExe layoutSetupScript}";
                };
            };

            timers.zellij-layout-setup = {
                Install.WantedBy = [ "timers.target" ];
                Timer = {
                    OnCalendar = [ "06:00" "18:00" ];
                    Persistent = true;
                    RandomizedDelaySec = "1m";
                };
            };
        };
    };
}
