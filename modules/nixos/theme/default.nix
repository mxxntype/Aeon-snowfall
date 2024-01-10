# INFO: Nixos `theme` module.

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
        };
    };
    
    config = {
        # Inherit theme theme from Home-manager's configuration
        aeon = {
            inherit (config.home-manager.users."user".aeon) theme;
        };

        # Serialize the inherited theme to /etc/theme.*
        environment.etc = let
            inherit (config.aeon) theme;
        in {
            "theme.json".text = builtins.toJSON theme;
            "theme.toml".text = lib.nix-std.serde.toTOML theme;
        };
    };
}
