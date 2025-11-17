{ lib, config, ... }: let

baseTheme  = lib.aeon.themes.dark-plus;
themeTemplate = lib.aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };

theme = lib.aeon.mkTheme {
    inherit themeTemplate;
    overrides = {
        ui.accent = themeTemplate.colors.yellow;
    };
};

in {
    config = lib.mkIf (config.aeon.style.codename == "dark-plus") {
        aeon = {
            inherit theme;
            style = {
                themeFallbacks.helix = "dark_plus";
                fonts = {
                    text = "Nunito";
                    code = "ZedMono NF";
                    decoration = "BigBlueTermPlus Nerd Font";
                };
            };
        };
    };
}
