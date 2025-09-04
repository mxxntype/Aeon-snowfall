{ lib, config, ... }: with lib; let

baseTheme  = aeon.themes.rose-pine-moon;
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
    config = mkIf (config.aeon.style.codename == "rose-pine-moon") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "rose_pine_moon";
            };
        };
    };
}
