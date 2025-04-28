# INFO: A style inspired by the woods.

{ lib, config, ... }:

with lib;
let
    baseTheme  = aeon.themes.miasma;
    themeTemplate = aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };
    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = { /* TODO */ };
    };
in

{
    config = mkIf (config.aeon.style.codename == "miasma") {
        aeon = {
            inherit theme;
            style = {
                # TODO: Make a "nix" theme.
                themeFallbacks.helix = "base16_default";
            };
        };
    };
}
