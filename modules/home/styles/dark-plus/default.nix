{ lib, config, ... }: let

baseTheme  = lib.aeon.themes.dark-plus;
themeTemplate = lib.aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };

theme = lib.aeon.mkTheme {
    inherit themeTemplate;
    overrides = {
        ui.accent = themeTemplate.colors.green;
    };
};

in {
    config = lib.mkIf (config.aeon.style.codename == "dark-plus") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "dark_plus";
                fonts = {
                    code = "ZedMono NF";
                    text = "Exo 2";
                    decoration = "BigBlueTermPlus Nerd Font";
                };
            };
        };
    };
}
