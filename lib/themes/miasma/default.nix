# INFO: miasma.nvim theme.

{
    ...
}: let
    meta = {
        name = "Miasma.nvim";
        slug = "miasma";
        style = "dark";
        url = "https://github.com/xero/miasma.nvim";
    };
in {
    themes = {
        ${meta.slug} = {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "111111";
                mantle    = "1C1C1C";
                base      = "222222";
                surface0  = "444444";
                surface1  = "555555";
                surface2  = "5F5F5F";
                overlay0  = "666666";
                overlay1  = "787878";
                subtext0  = "D0BA70";
                subtext1  = "D6C383";
                text      = "C2C2B0";

                # Accent colors.
                red       = "685742";
                maroon    = "685742";
                peach     = "B36D43";
                flamingo  = "B36D43";
                rosewater = "C9A554";
                yellow    = "C9A554";
                green     = "5E875E";
                cyan      = "5E875E";
                teal      = "5E875E";
                sky       = "78814A";
                sapphire  = "78814A";
                blue      = "78814A";
                lavender  = "D6C383";
                mauve     = "78814A";
                pink      = "78814A";
            };

            inherit meta;
        };
    };
}
