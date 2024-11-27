# INFO: A cool, pastel style based on the Catppuccin mocha theme.

{
    lib,
    config,
    ...
}:

with lib;
let
    baseTheme  = aeon.themes.catppuccin-mocha;
    themeTemplate = aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };
    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = { /* TODO */ };
    };
in

{
    config = mkIf (config.aeon.style.codename == "pastel") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "catppuccin_mocha";
            };
        };
    };
}
