# INFO: A style inspired by the colors of the famous painting by Katsushika Hokusai.

{ lib, config, ... }:

let
    baseTheme  = lib.aeon.themes.kanagawa-wave;
    themeTemplate = lib.aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };

    theme = lib.aeon.mkTheme {
        inherit themeTemplate;
        overrides = { };
    };
in

{
    config = lib.mkIf (config.aeon.style.codename == "kanagawa-wave") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "kanagawa";
            };
        };
    };
}
