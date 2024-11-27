# INFO: Home-manager styling module.

{
    lib,
    config,
    ...
}:

with builtins;
with lib; 

let
    # Automatically detect possible styles.
    directoryContents = readDir ./.;
    possibleCodenames = directoryContents
        |> attrNames
        |> filter (f: directoryContents."${f}" == "directory");

    # Wallpapers found in styles' subdirs.
    wallpapers = {
        byCodename = { codename }: (readDir ./${codename}/wallpapers)
            |> attrNames
            |> map (basename: "${codename}/wallpapers/${basename}");
        all = possibleCodenames
            |> map (codename: wallpapers.byCodename { inherit codename; })
            |> flatten;
    };
in

{
    options.aeon.style = {
        wm = mkOption {
            type = with types; attrs;
            default = { };
        };

        themeFallbacks = {
            helix = mkOption {
                type = with types; nullOr str;
                default = null;
            };
        };

        codename = mkOption {
            type = with types; nullOr (enum possibleCodenames);
            default = null;
        };
    };

    config = let
        inherit (config.aeon.style) codename;
    in mkIf (codename != null) {
        xdg.configFile = mkMerge [
            (wallpapers.byCodename { inherit codename; }
                |> map (wp: { name = "wallpapers/current/${wp}"; value.source = ./${wp}; })
                |> listToAttrs)
            (wallpapers.all
                |> map (wp: { name = "wallpapers/${wp}"; value.source = ./${wp}; })
                |> listToAttrs)
        ];
    };
}
