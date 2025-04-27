# INFO: evangelion.nvim theme.

{
    ...
}: let
    meta = {
        name = "Evangelion.nvim";
        slug = "evangelion";
        style = "dark";
        url = "https://github.com/xero/evangelion.nvim";
    };
in {
    themes = {
        ${meta.slug} = {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "14091E";
                mantle    = "14091E";
                base      = "201430";
                surface0  = "39274D";
                surface1  = "483160";
                surface2  = "67478A";
                overlay0  = "74509b";
                overlay1  = "805aaa";
                subtext0  = "d1c0f4";
                subtext1  = "E1D6F8";
                text      = "CCD2D9";

                # Accent colors.
                red       = "5b2b41";
                maroon    = "DB6088";
                peach     = "fab387";
                flamingo  = "E6BB85";
                rosewater = "E6BB85";
                yellow    = "E6BB85";
                green     = "9CDA7C";
                cyan      = "87ff5f";
                teal      = "9DAFD1";
                sky       = "A4D2EC";
                sapphire  = "CE67F0";
                blue      = "B968FC";
                lavender  = "CE67F0";
                mauve     = "875faf";
                pink      = "AB92FC";
            };

            inherit meta;
        };
    };
}
