{ config, pkgs, lib, ... }:

{
    options.aeon.apps.wezterm = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.apps.wezterm) enable;
        inherit (config.aeon.theme) colors ui;
        inherit (config.aeon) style;
    in lib.mkIf enable rec {
        aeon.apps.defaultTerminal = programs.wezterm.package;
        programs.wezterm = {
            inherit enable;
            package = pkgs.wezterm;
            extraConfig = /* lua */ ''
                local wezterm = require "wezterm"

                local _font = wezterm.font_with_fallback{
                    {
                        family = "${style.fonts.code}",
                    },
                }

                local config = {
                    enable_tab_bar = false,
                    default_cursor_style = 'BlinkingUnderline';
                    cursor_blink_rate = 600;
                    cursor_blink_ease_in  = 'Constant';
                    cursor_blink_ease_out = 'Constant';

                    colors = {
                        background = "#${ui.bg.base}",
                        foreground = "#${ui.fg.text}",
                        cursor_fg = "#${ui.bg.overlay0}",

                        ansi = {
                            "#${ui.bg.crust}",    -- Black.
                            "#${colors.red}",     -- Red.
                            "#${colors.green}",   -- Green.
                            "#${colors.yellow}",  -- Yellow.
                            "#${colors.blue}",    -- Blue.
                            "#${colors.mauve}",   -- Mauve.
                            "#${colors.cyan}",    -- Cyan.
                            "#${ui.fg.subtext1}", -- White.
                        },

                        brights = {
                            "#${ui.bg.overlay1}", -- Black.
                            "#${colors.red}",     -- Red.
                            "#${colors.green}",   -- Green.
                            "#${colors.yellow}",  -- Yellow.
                            "#${colors.blue}",    -- Blue.
                            "#${colors.mauve}",   -- Mauve.
                            "#${colors.cyan}",    -- Cyan.
                            "#${ui.fg.text}",     -- White.
                        },

                        -- NOTE: For `bacon`.
                        indexed = {
                            [204] = "#${colors.mauve}",
                            [239] = "#${colors.surface2}",
                            [240] = "#${colors.surface2}",
                            [252] = "#${colors.subtext0}",
                            [255] = "#${colors.text}",
                        };
                    },

                    font = _font,
                    font_size = 16,
                    font_rules = {
                        { -- Don't use bold fonts.
                            intensity = "Bold",
                            font = _font,
                        },
                        -- { -- Don't use italics.
                        --     italic = true,
                        --     font = _font,
                        -- },
                    },
                }

                return config
            '';
        };
    };
}
