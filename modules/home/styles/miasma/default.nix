# INFO: A style inspired by the woods.

{ lib, config, ... }:

with lib;
let
    baseTheme  = aeon.themes.miasma;
    inherit (baseTheme)
        colors
        # meta
        ;

    themeTemplate = aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };

    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = {
            code = {
                keyword = colors.green;
                string = colors.red;
                comment = colors.surface2;
                linenr = colors.surface2;
            };
        };
    };
in

{
    config = mkIf (config.aeon.style.codename == "miasma") {
        aeon = {
            inherit theme;
            style = { };
        };
    };
}
