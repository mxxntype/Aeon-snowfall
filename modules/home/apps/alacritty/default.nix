{ config, lib, ... }: with lib;

{
    options.aeon.apps.alacritty = {
        enable = mkOption {
            type = types.bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.apps.alacritty)
            enable
            ;
        inherit (config.aeon.theme)
            ui
            colors
            ;
    in mkIf enable {
        programs.alacritty = {
            enable = true;
            settings = {
                window.padding = {
                    x = 14; y = 14;
                };

                font = let
                    family = "IosevkaAeon Nerd Font";
                in {
                    size = 16;
                    normal = {
                        inherit family;
                        style = "Regular";
                    };
                    bold = {
                        inherit family;
                        style = "Medium";
                    };
                    italic = {
                        inherit family;
                        style = "Italic";
                    };
                    bold_italic = {
                        inherit family;
                        style = "Medium Italic";
                    };
                };

                colors = {
                    primary = {
                        background = "#${ui.bg.base}";
                        foreground = "#${ui.fg.text}";
                    };

                    normal = {
                        black = "#${ui.bg.crust}";
                        white = "#${ui.fg.subtext1}";
                        red = "#${colors.red}";
                        yellow = "#${colors.yellow}";
                        green = "#${colors.green}";
                        cyan = "#${colors.cyan}";
                        blue = "#${colors.blue}";
                        magenta = "#${colors.mauve}";
                    };

                    bright = {
                        black = "#${ui.bg.overlay1}";
                        white = "#${ui.fg.text}";
                        red = "#${colors.red}";
                        yellow = "#${colors.yellow}";
                        green = "#${colors.green}";
                        cyan = "#${colors.cyan}";
                        blue = "#${colors.blue}";
                        magenta = "#${colors.mauve}";
                    };

                    selection = {
                        background = "#${ui.bg.surface1}";
                        foreground = "#${ui.accent}";
                    };

                    indexed_colors = [
                        # NOTE: For `bacon`.
                        { index = 204; color = "#${colors.mauve}"; }
                        { index = 239; color = "#${colors.surface0}"; }
                        { index = 240; color = "#${colors.surface0}"; }
                        { index = 252; color = "#${colors.subtext0}"; }
                        { index = 255; color = "#${colors.text}"; }
                    ];
                };
            };
        };
    };
}
