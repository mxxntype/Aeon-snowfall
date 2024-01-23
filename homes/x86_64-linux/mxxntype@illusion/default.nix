{
    config,
    lib,
    ...
}:

{
    aeon = {
        # WARN: Respective NixOS option (`aeon.theme`) inherits this attrset.
        theme = with lib.aeon; let 
            theme = themes.everforest-twilight;
        in mkTheme {
            themeTemplate = mkThemeTemplate { inherit (theme) colors meta; };
            overrides = {};
        };
    };

    home = {
        homeDirectory = "/home/${config.home.username}";
        stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
    };
}

