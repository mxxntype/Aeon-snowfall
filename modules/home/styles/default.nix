# INFO: Home-manager styling module.

{
    lib,
    config,
    ...
}:

with lib; 
let
    # Automatically detect possible styles.
    directoryContents = builtins.readDir ./.;
    possibleCodenames = builtins.filter (e: directoryContents.${e} == "directory")
                                     (builtins.attrNames directoryContents);

    # Storage for whatever data.
    mkAttrsOption = mkOption {
        type = with types; attrs;
        default = { };
    };

    # Wallpapers found in styles' subdirs.
    wallpapers = {
        byCodename = { codename }: builtins.attrNames (builtins.readDir ./${codename}/wallpapers);
        all = flatten (builtins.map (codename: builtins.map (wp: "${codename}/wallpapers/${wp}") (wallpapers.byCodename { inherit codename; })) possibleCodenames);
    };
in

{
    options.aeon.style = {
        codename = mkOption {
            type = with types; nullOr (enum possibleCodenames);
            default = null;
        };

        wm = mkAttrsOption;
    };

    config = let
        inherit (config.aeon.style) codename;
    in mkIf (codename != null) {
        xdg.configFile = mkMerge [
            # Wallpapers that belong to the current theme live in ~/.config/wallpapers/current/
            (builtins.listToAttrs (builtins.map (wp: {
                name = "wallpapers/current/${wp}";
                value = { source = ./${codename}/wallpapers/${wp}; };
            }) (wallpapers.byCodename { inherit codename; })))

            # Wallpapers that do NOT belong to the current theme live in ~/.config/wallpapers/<codename>/
            (builtins.listToAttrs (builtins.map (wp: {
                name = "wallpapers/${wp}";
                value = { source = ./${wp}; };
            }) wallpapers.all))
        ];
    };
}
