_: let

meta = {
    name = "Dark+";
    slug = "dark-plus";
    style = "dark";
};

in {
    themes.${meta.slug} = {
        colors = rec {
            # Backgrounds and foregrounds.
            void      = "000000";
            crust     = "111111";
            mantle    = "111111";
            base      = "1E1E1E";
            surface0  = "282828";
            surface1  = "3a3d41";
            surface2  = "404040";
            overlay0  = "656565";
            overlay1  = overlay0;
            overlay2  = overlay1;
            subtext0  = subtext1;
            subtext1  = "A6A6A6";
            text      = "D4D4D4";

            # Accent colors.
            red       = "F14C4C";
            maroon    = "F14C4C";
            peach     = "CE9178";
            flamingo  = "CE9178";
            rosewater = "DCDCAA";
            yellow    = "DCDCAA";
            green     = "6A9955";
            cyan      = lavender;
            teal      = lavender;
            sky       = "75BEFF";
            sapphire  = "6796E6";
            blue      = "569CD6";
            lavender  = "9CDCFE";
            mauve     = "4EC9B0";
            pink      = "C586C0";
        };

        inherit meta;
    };
}
