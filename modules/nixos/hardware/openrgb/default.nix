{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.openrgb = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };

        color = lib.mkOption { type = lib.types.str; };
        resizeableZones = {
            device_id = lib.mkOption { type = lib.types.int; };
            zone_ids = lib.mkOption { type = lib.types.listOf lib.types.int; };
            size = lib.mkOption { type = lib.types.int; };
        };
    };

    config = let
        inherit (config.aeon.hardware.openrgb)
            enable
            color
            resizeableZones
            ;

        services = {
            daemon = "openrgb";
            setup = "openrgb-setup";
        };
    in lib.mkIf enable {
        environment.systemPackages = [ pkgs.aeon.openrgb ];

        systemd.services."${services.daemon}" = {
            description = "OpenRGB daemon";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                ExecStart = [ "${lib.getExe pkgs.aeon.openrgb} --server --server-host 127.0.0.1" ];
            };
        };

        systemd.services."${services.setup}" = {
            description = "OpenRGB setup job";
            after = [ "${services.daemon}.service" ];
            requires = [ "${services.daemon}.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = let zone_setup_commands = resizeableZones.zone_ids
                    |> builtins.map (zone_id: [
                        "${lib.getExe pkgs.aeon.openrgb}"
                        "--device ${toString resizeableZones.device_id}"
                        "--zone ${toString zone_id}"
                        "--size ${toString resizeableZones.size}"
                        "--color 000000"] |> builtins.concatStringsSep " " );
                in [ "${lib.getExe pkgs.aeon.openrgb} --color ${color}" ]
                    ++ zone_setup_commands
                    ++ [ "${lib.getExe pkgs.aeon.openrgb} --color ${color}" ];
            };
        };
    };
}
