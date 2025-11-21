{ lib, config, ... }: let

inherit (lib) mkOption types;

in {
    options.aeon.monitors = {
        monitors = mkOption {
            type = types.listOf (types.submodule {
                options = {
                    enable = mkOption { type = types.bool; default = true; };
                    name = mkOption { type = types.str; };
                    port = mkOption { type = types.str; };
                    width = mkOption { type = types.int; };
                    height = mkOption { type = types.int; };
                    refreshRate = mkOption { type = types.int; };
                    scale = mkOption { type = types.float; };
                    offsetX = mkOption { type = types.int; };
                    offsetY = mkOption { type = types.int; };
                    workspaces = mkOption { type = types.listOf types.int; };
                    showBar = mkOption { type = types.bool; };
                };
            });
        };

        maxRefreshRate = mkOption { type = types.int; };
    };

    config.aeon.monitors = let
        refreshRates = config.aeon.monitors.monitors
            |> builtins.filter (monitor: monitor.enable)
            |> builtins.map (monitor: monitor.refreshRate);
    in {
        maxRefreshRate = builtins.foldl' lib.max 0 refreshRates;
    };
}
