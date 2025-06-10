{ lib, ... }: let

inherit (lib) mkOption types;
inherit (types)
    bool
    float
    int
    listOf
    str
    submodule
    ;

in {
    options.aeon.monitors = mkOption {
        type = listOf (submodule {
            options = {
                enable = mkOption { type = bool; default = true; };
                name = mkOption { type = str; };
                port = mkOption { type = str; };
                width = mkOption { type = int; };
                height = mkOption { type = int; };
                refreshRate = mkOption { type = int; };
                scale = mkOption { type = float; };
                offsetX = mkOption { type = int; };
                offsetY = mkOption { type = int; };
                workspaces = mkOption { type = listOf int; };
                showBar = mkOption { type = types.bool; };
            };
        });
    };
}
