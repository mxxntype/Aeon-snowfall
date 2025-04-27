# INFO: A style inspired by neon genesis evangelion.

{ lib, config, ... }:

with lib;
let
    baseTheme  = aeon.themes.evangelion;
    themeTemplate = aeon.mkThemeTemplate { inherit (baseTheme) colors meta; };
    theme = aeon.mkTheme {
        inherit themeTemplate;
        overrides = { /* TODO */ };
    };
in

{
    config = mkIf (config.aeon.style.codename == "evangelion") {
        aeon = {
            inherit theme;
            style = {
                # TODO: Make a "nix" theme.
                themeFallbacks.helix = "base16_default";
            };
        };
    };
}
