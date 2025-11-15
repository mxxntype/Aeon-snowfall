_: let

meta = {
    name = "Everforest Twilight";
    slug = "everforest-twilight";
    style = "dark";
    url = "https://github.com/sainnhe/everforest";
};

in {
    themes = {
        ${meta.slug} = rec {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "0e0d11";
                mantle    = "0e0d11";
                base      = "0e0d11";
                surface0  = "1d1b22";
                surface1  = "2e383c";
                surface2  = "374145";
                overlay0  = "414b50";
                overlay1  = "495156";
                overlay2  = "7a8478";
                subtext0  = "859289";
                subtext1  = "9da9a0";
                text      = "d3c6aa";

                # Accent colors.
                red       = "e67e80";
                maroon    = "e67e80";
                peach     = "e69875";
                yellow    = "dbbc7f";
                rosewater = "dbbc7f";
                flamingo  = "dbbc7f";
                green     = "a7c080";
                teal      = "83c092";
                cyan      = colors.teal;
                sky       = "83c092";
                sapphire  = "7fbbb3";
                blue      = "7fbbb3";
                lavender  = "d3c6aa";
                mauve     = "d699b6";
                pink      = "d699b6";
            };

            inherit meta;
        };
    };
}
