{ config, lib, pkgs, ... }:

{
    options.aeon.hardware.openrgb = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };

        devices = lib.mkOption {
            default = [ ];
            type = lib.types.listOf (lib.types.submodule {
                options = {
                    id = lib.mkOption { type = lib.types.int; };
                    zoneIds = lib.mkOption { type = lib.types.listOf lib.types.int; };
                    resizeableZoneIds = lib.mkOption { type = lib.types.listOf lib.types.int; };
                    resizeableZoneSize = lib.mkOption { type = lib.types.int; };
                    mode = lib.mkOption { type = lib.types.str; };
                    color = lib.mkOption { type = lib.types.str; };
                };
            });
        };
    };

    config = let
        inherit (config.aeon.hardware.openrgb)
            enable
            devices
            ;

        services = {
            daemon = "openrgb";
            setup = "openrgb-setup";
            restart = "openrgb-restart";
        };
    in lib.mkIf enable {
        environment.systemPackages = [ pkgs.aeon.openrgb ];
        systemd = {
            services."${services.daemon}" = {
                description = "OpenRGB daemon";
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                    Restart = "on-failure";
                    ExecStart = [ "${lib.getExe pkgs.aeon.openrgb} --server --server-host 127.0.0.1" ];
                };
            };

            services."${services.setup}" = {
                description = "OpenRGB setup job";
                after = [ "${services.daemon}.service" ];
                requires = [ "${services.daemon}.service" ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                    Type = "oneshot";
                    Restart = "on-failure";
                    RestartSec = "10s";
                    TimeoutStartSec = "10s";
                    ExecStart = devices
                        |> builtins.map (device:
                            (device.zoneIds |> builtins.map (zone_id: [
                                "${lib.getExe pkgs.aeon.openrgb}"
                                "--device ${toString device.id}"
                                "--zone ${toString zone_id}"
                                "--mode ${device.mode}"
                                "--color ${device.color}"
                            ] |> builtins.concatStringsSep " "))
                            ++
                            (device.resizeableZoneIds |> builtins.map (zone_id: [
                                "${lib.getExe pkgs.aeon.openrgb}"
                                "--device ${toString device.id}"
                                "--zone ${toString zone_id}"
                                "--size ${toString device.resizeableZoneSize}"
                                "--mode ${device.mode}"
                                "--color ${device.color}"
                            ] |> builtins.concatStringsSep " "))
                        )
                        |> lib.flatten;
                };
            };

            services.${services.restart}.serviceConfig = {
                Type = "oneshot";
                ExecStart = [
                    "systemctl restart ${services.daemon}.service"
                    "systemctl restart ${services.setup}.service"
                ];
            };

            timers.${services.restart} = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                    OnBootSec = "30s";
                    Persistent = false;
                };
            };
        };
    };
}
