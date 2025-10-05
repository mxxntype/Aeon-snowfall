# INFO: Home-manager Minecraft module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.games.minecraft = {
        enable = mkOption { type = with types; bool;
            default = false;
            description = "Whether to enable Minecraft";
        };
    };

    config = let
        inherit (config.aeon.games.minecraft)
            enable
            ;
        inherit (config.aeon.theme)
            ui
            code
            ;
    in mkIf enable {
        home = {
            packages = with pkgs; [
                jdk17         # Java Development Kit.
                prismlauncher # Launcher for Minecraft.
                packwiz       # CLI tool for creating modpacks.
            ];

            # INFO: Create a theme for PrismLauncher.
            file = {
                ".local/share/PrismLauncher/themes/custom/theme.json".text = builtins.toJSON {
                    colors = {
                        Base = "#${ui.bg.base}";
                        AlternateBase = "#${ui.bg.surface0}";
                        BrightText = "#${ui.fg.text}";
                        Button = "#${ui.bg.surface1}";
                        ButtonText = "#${ui.fg.text}";
                        Highlight = "#${ui.accent}";
                        HighlightText = "#${ui.bg.base}";
                        Link = "#${code.url}";
                        Text = "#${ui.fg.text}";
                        ToolTipBase = "#${ui.bg.base}";
                        ToolTipText = "#${ui.fg.text}";
                        Window = "#${ui.bg.base}";
                        WindowText = "#${ui.fg.text}";
                        fadeAmount = 0.5;
                        fadeColor = "#${ui.bg.surface0}";
                    };
                    name = "Nix Dynamic";
                    qssFilePath = "themeStyle.css";
                    widgets = "Fusion";
                };

                ".local/share/PrismLauncher/themes/custom/themeStyle.css".text = /* css */ ''
                    QToolTip {
                        color: #${ui.fg.text};
                        background-color: #${ui.bg.base};
                        border: 2px solid #${ui.bg.surface0};
                    }
                '';
           };
        };
    };
}
