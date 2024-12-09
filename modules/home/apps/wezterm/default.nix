# INFO: Wezterm, a powerful cross-platform terminal emulator and multiplexer.

{
    config,
    pkgs,
    lib,
    ...
}:

with lib;

{
    options.aeon.apps.wezterm = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable WezTerm";
        };
    };

    config = let
        inherit (config.aeon.apps.wezterm)
            enable
            ;
    in mkIf enable {
        programs.wezterm = {
            inherit enable;
            package = pkgs.aeon.wezterm;
            extraConfig = /* lua */ ''
                local wezterm = require "wezterm"

                local _font = wezterm.font_with_fallback{
                    {
                        family = "IosevkaAeon Nerd Font",
                    },
                }

                local config = {
                    enable_tab_bar = false,
                    color_scheme = "Catppuccin Mocha",
                    -- colors = {
                    --     background = "#0d0e16",
                    --     foreground = "#ffffff",
                    --     cursor_fg = "#8041d8",

                    --     ansi = {
                    --         "#1e1e33", -- Black.
                    --         "#d83441", -- Red.
                    --         "#79d836", -- Green.
                    --         "#d8b941", -- Yellow.
                    --         "#3679d8", -- Blue.
                    --         "#8041d8", -- Mauve.
                    --         "#36d8bd", -- Teal.
                    --         "#c3dbe5", -- White.
                    --     },

                    --     brights = {
                    --         "#464a56", -- Black.
                    --         "#d83441", -- Maroon.
                    --         "#79d836", -- Green.
                    --         "#d8b941", -- Flamingo.
                    --         "#3679d8", -- Sky.
                    --         "#8041d8", -- Pink
                    --         "#36d8bd", -- Cyan.
                    --         "#ffffff", -- White.
                    --     },
                    -- },

                    font = _font,
                    font_size = 16,
                    -- font_rules = {
                    --     {
                    --         -- Don't use bold fonts.
                    --         intensity = "Bold",
                    --         font = _font,
                    --     },
                    --     {
                    --         -- Don't use italics.
                    --         italic = true,
                    --         font = _font,
                    --     },
                    -- },

                    -- Scale the font if needed (not recommended though)
                    -- cell_width = 1.0,
                    -- line_height = 1.0,
                }

                return config
            '';
        };
    };
}
