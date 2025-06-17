# INFO: A style inspired by the colors of the famous painting by Katsushika Hokusai.

{ lib, config, ... }: with lib; let

baseTheme  = aeon.themes.kanagawa-dragon;
inherit (baseTheme)
    colors
    meta
    ;

themeTemplate = aeon.mkThemeTemplate { inherit colors meta; };

theme = aeon.mkTheme {
    inherit themeTemplate;
    overrides = { };
};

in {
    config = mkIf (config.aeon.style.codename == "kanagawa-dragon") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "kanagawa-dragon";
            };
        };
    };
}
