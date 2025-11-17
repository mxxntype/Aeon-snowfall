{ lib, ... }:

let

# Automatically detect possible styles.
directoryContents = builtins.readDir ./.;
possibleCodenames = directoryContents
    |> builtins.attrNames
    |> builtins.filter (f: directoryContents."${f}" == "directory");

in {
    options.aeon.style = {
        codename = lib.mkOption {
            type = with lib.types; nullOr (enum possibleCodenames);
            default = null;
        };

        fonts = {
            text = lib.mkOption { type = lib.types.str; };
            code = lib.mkOption { type = lib.types.str; };
            decoration = lib.mkOption { type = lib.types.str; };
        };

        themeFallbacks = {
            helix = lib.mkOption {
                type = with lib.types; nullOr str;
                default = null;
            };
        };
    };
}
