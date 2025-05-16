# INFO: A style inspired by neon genesis evangelion.

{ lib, config, ... }:

with lib;
let
    baseTheme  = aeon.themes.evangelion;
    inherit (baseTheme)
        colors
        meta
        ;

    themeTemplate = aeon.mkThemeTemplate { inherit colors meta; };

    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = {
            code = {
                keyword = colors.green;
                string = colors.mauve;
                comment = colors.surface2;
                linenr = colors.surface2;
            };
        };
    };
in

{
    config = mkIf (config.aeon.style.codename == "evangelion") {
        aeon = {
            inherit theme;
            style = { };
        };
    };
}
