# INFO: Catppuccin Mocha theme

{
    ...
}: let
    meta = {
        name = "Catppuccin Mocha";
        slug = "catppuccin-mocha";
        style = "dark";
        url = "https://github.com/catppuccin";
    };
in {
    themes = {
        ${meta.slug} = rec {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "11111c";
                mantle    = "181825";
                base      = "1e1e2e";
                surface0  = "313244";
                surface1  = "45475a";
                surface2  = "585b70";
                overlay0  = "6c7086";
                overlay1  = "7f849c";
                subtext0  = "a6adc8";
                subtext1  = "bac2de";
                text      = "cdd6f4";

                # Accent colors.
                red       = "f38ba8";
                maroon    = "eda0ab";
                peach     = "fab387";
                flamingo  = "f5e0dc";
                rosewater = "f2cdcd";
                yellow    = "f9e2af";
                green     = "a6e3a1";
                cyan      = colors.teal;
                teal      = "94e2d5";
                sky       = "89dceb";
                sapphire  = "74c7ec";
                blue      = "89b4fa";
                lavender  = "b4befe";
                mauve     = "cba6f7";
                pink      = "f5c2e7";
            };

            inherit meta;
        };
    };
}
