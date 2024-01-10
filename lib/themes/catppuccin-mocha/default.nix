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
        ${meta.slug} = {
            accent ? "mauve",
            ...
        }: rec {
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
                yellow    = "f5e2af";
                green     = "a6e3a1";
                cyan      = colors.teal;
                teal      = "94e2d5";
                sky       = "98dceb";
                sapphire  = "74c7ec";
                blue      = "89b4fa";
                lavender  = "b4befe";
                mauve     = "cba6f7";
                pink      = "f5c2e7";
            };

            ui = with colors; {
                bg = {
                    inherit void crust mantle base;
                    inherit surface0 surface1 surface2;
                    inherit overlay0 overlay1;
                };

                fg = {
                    inherit subtext0 subtext1;
                    inherit text;
                };

                # For light stuff in dark themes.
                alternate = {
                    bg = {
                        base = text;
                        surface = subtext1;
                    };
                    fg = {
                        subtext = base;
                        text = void;
                    };
                };

                accent = colors.${accent};
                subtle = lavender;
                info   = sky;
                ok     = green;
                warn   = yellow;
                error  = red;
            };

            # Syntax highlighting colors. TODO: Add more.
            code = with colors; {
                variable  = text;
                argument  = red;
                namespace = yellow;
                type      = yellow;
                struct    = code.type;
                enum      = sky;
                function  = blue;
                macro     = mauve;
                primitive = rosewater;
                number    = code.primitive;
                boolean   = code.primitive;
                constant  = peach;
                string    = green;
                char      = green;
                escape    = pink;
                comment   = subtext0;
            };

            # Shell colors.
            cli = with colors; {
                builtin  = teal;
                external = blue;
                notfound = red;
                argument = teal;

                # TODO: Make LS_COLORS overridable?
                # ls = {};
            };

            # VCS stuff.
            diff = with colors; {
                plus = green;
                minus = red;
                delta = blue;
            };

            inherit meta;
        };
    };
}
