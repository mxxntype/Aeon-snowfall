# INFO: A green, warm style based on the Everforest theme. WARN: WIP!

{
    lib,
    config,
    ...
}:

with lib;
let
    baseTheme  = aeon.themes.everforest-twilight;
    themeTemplate = aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };
    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = { /* TODO */ };
    };
in

{
    config = mkIf (config.aeon.style.codename == "overgrowth") {
        aeon = {
            inherit theme;
            style = {
                wm = { };
            };
        };
    };
}
