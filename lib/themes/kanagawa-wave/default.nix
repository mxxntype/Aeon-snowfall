_: let

meta = {
    name = "Kanagawa Wave";
    slug = "kanagawa-wave";
    style = "dark";
    url = "https://github.com/rebelot/kanagawa.nvim";
};

in {
    themes = {
        ${meta.slug} = {
            colors = rec {
                # Backgrounds and foregrounds.
                void      = "000000";
                crust     = "16161D";
                mantle    = "16161D";
                base      = "1F1F28";
                surface0  = "2A2A37";
                surface1  = "363646";
                surface2  = "54546D";
                overlay0  = surface2;
                overlay1  = surface2;
                overlay2  = surface2;
                subtext0  = "727169";
                subtext1  = "C8C093";
                text      = "DCD7BA";

                # Accent colors.
                red       = "E46876";
                maroon    = "FF5D62";
                peach     = "FFA066";
                flamingo  = "E6C384";
                rosewater = "E6C384";
                yellow    = "DCA561";
                green     = "98BB6C";
                cyan      = "7FB4CA";
                teal      = "6A9589";
                sky       = "A3D4D5";
                sapphire  = "658594";
                blue      = "7E9CD8";
                lavender  = "9CABCA";
                mauve     = "957FB8";
                pink      = "D27E99";
            };

            inherit meta;
        };
    };
}
