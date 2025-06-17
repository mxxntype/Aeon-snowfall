{ ... }: let

meta = {
    name = "Kanagawa Dragon";
    slug = "kanagawa-dragon";
    style = "dark";
    url = "https://github.com/rebelot/kanagawa.nvim";
};

in {
    themes = {
        ${meta.slug} = {
            colors = {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "12120F";
                mantle    = "1D1C19";
                base      = "181616";
                surface0  = "282727";
                surface1  = "363646";
                surface2  = "393836";
                overlay0  = "625E5A";
                overlay1  = "7A8382";
                subtext0  = "9E9B93";
                subtext1  = "C8C093";
                text      = "C5C9C5";

                # Accent colors.
                red       = "C4746E";
                maroon    = "E46876";
                peach     = "FFA066";
                flamingo  = "A292A3";
                rosewater = "C4B28A";
                yellow    = "E6C384";
                green     = "8A9A7B";
                cyan      = "8EA4A2";
                teal      = "7AA89F";
                sky       = "A3D4D5";
                sapphire  = "7FB4CA";
                blue      = "8BA4B0";
                lavender  = "9CABCA";
                mauve     = "957FB8";
                pink      = "A292A3";

                special = { };
            };

            inherit meta;
        };
    };
}
