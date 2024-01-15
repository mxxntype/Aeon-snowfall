# INFO: NixOS `theme` module.

{
    lib,
    config,
    ...
}:

with lib; {
    options = {
        aeon.theme = mkOption {
            description = "Theme attrset for NixOS (inherited from Home-manager)";
            type = types.attrs;

            # FIXME: Provide `default` theme.
            default = with lib.aeon; let 
                theme = themes.catppuccin-mocha;
            in mkTheme {
                themeTemplate = mkThemeTemplate { inherit (theme) colors meta; };
                overrides = {};
            };
        };
    };
    
    config = mkIf (builtins.hasAttr "${aeon.user}" config.home-manager.users) {
        # Inherit theme theme from Home-manager's configuration
        aeon = {
            inherit (config.home-manager.users.${aeon.user}.aeon) theme;
        };

        # Serialize the inherited theme to /etc/theme.*
        environment.etc = let
            inherit (config.aeon) theme;
        in {
            "theme.json".text = builtins.toJSON theme;
            "theme.toml".text = nix-std.serde.toTOML theme;
        };
    };
}
