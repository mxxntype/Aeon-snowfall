# INFO: Home-manager `theme` module.

{
    lib,
    config,
    ...
}:

with lib; {
    options = {
        aeon.theme = mkOption {
            description = "Theme attrset for Home-manager";
            type = types.attrs;
        };
    };

    config = {
        # Serialize the theme to $XDG_CONFIG_HOME/theme.*
        xdg.configFile = let
            theme = config.aeon.theme;
        in {
            "theme.json".text = builtins.toJSON theme;
            "theme.toml".text = lib.nix-std.serde.toTOML theme;
        };
    };
}
