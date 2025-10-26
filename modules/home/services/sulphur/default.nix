{ lib, pkgs, config, ... }:

{
    options.aeon.services.sulphur = {
        enable = lib.mkOption { type = lib.types.bool; default = false; };
        settings = {
            api_address = lib.mkOption { type = lib.types.str; default = "127.0.0.1:8899"; };
            graph_length = lib.mkOption { type = lib.types.int; default = 5; };
            span_seconds = lib.mkOption { type = lib.types.int; default = 10; };
        };
    };

    config = let inherit (config.aeon.services.sulphur) enable settings;
    in lib.mkIf enable {
        systemd.user.services."sulphur-server" = {
            Unit = { After = [ "network.target" ]; };
            Install = { WantedBy = [ "default.target" ]; };
            Service = {
                Restart = "on-failure";
                ExecStart = builtins.concatStringsSep " " [
                    "${pkgs.aeon.artificial_island}/bin/sulphur_server"
                    "--api-address ${settings.api_address}"
                    "--graph-length ${toString settings.graph_length}"
                    "--span-seconds ${toString settings.span_seconds}"
                ];
            };
        };
    };
}
