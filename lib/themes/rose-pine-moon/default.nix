_: let

meta = {
    name = "Rose Pine Moon";
    slug = "rose-pine-moon";
    style = "dark";
    url = "https://rosepinetheme.com";
};

in {
    themes = {
        ${meta.slug} = rec {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "1f1d30";
                mantle    = "211f33";
                base      = "232136";
                surface0  = "2a273f";
                surface1  = "2a283e";
                surface2  = "393552";
                overlay0  = "44415a";
                overlay1  = "56526e";
                subtext0  = "6e6a86";
                subtext1  = "908caa";
                text      = "e0def4";

                # Accent colors.
                red       = "eb6f92";
                maroon    = "ea9a97";
                peach     = colors.text;
                flamingo  = colors.text;
                rosewater = colors.text;
                yellow    = "f6c177";
                green     = "3e8fb0";
                cyan      = colors.text;
                teal      = colors.text;
                sky       = colors.text;
                sapphire  = colors.text;
                blue      = "9ccfd8";
                lavender  = colors.text;
                mauve     = "c4a7e7";
                pink      = colors.text;
            };

            inherit meta;
        };
    };
}
