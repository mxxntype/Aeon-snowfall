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

        job = "11119762635";
        openrgbAppimage = pkgs.appimageTools.wrapType2 {
            pname = "openrgb";
            version = "git-${job}";
            src = pkgs.fetchurl {
                url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/jobs/${job}/artifacts/raw/OpenRGB-x86_64.AppImage";
                hash = "sha256-INghItN4XKl/vrwwENFVOKrpJbfqesp2jtyYov1b21w=";
            };
        };
    in lib.mkIf enable {
        environment.systemPackages = [ openrgbAppimage ];

        systemd.services."${services.daemon}" = {
            description = "OpenRGB daemon";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                ExecStart = [ "${openrgbAppimage}/bin/openrgb --server" ];
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
                        "${lib.getExe openrgbAppimage}"
                        "--device ${toString resizeableZones.device_id}"
                        "--zone ${toString zone_id}"
                        "--size ${toString resizeableZones.size}"
                        "--color 000000"] |> builtins.concatStringsSep " " );
                in [ "${lib.getExe openrgbAppimage} --color ${color}" ]
                    ++ zone_setup_commands
                    ++ [ "${lib.getExe openrgbAppimage} --color ${color}" ];
            };
        };
    };
}
