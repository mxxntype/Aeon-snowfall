{ lib, ... }:

with builtins;
with lib; 

let

# Automatically detect possible styles.
directoryContents = readDir ./.;
possibleCodenames = directoryContents
    |> attrNames
    |> filter (f: directoryContents."${f}" == "directory");

in {
    options.aeon.style = {
        codename = mkOption {
            type = with types; nullOr (enum possibleCodenames);
            default = null;
        };

        themeFallbacks = {
            helix = mkOption {
                type = with types; nullOr str;
                default = null;
            };
        };
    };
}
