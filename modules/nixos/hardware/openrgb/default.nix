{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.hardware.openrgb = {
        enable = mkOption {
            type = types.bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.hardware.openrgb) enable color;
        services = {
            daemon = "openrgb";
            setup = "openrgb-setup";
        };

        profileName = "${config.networking.hostName}.orp";
        profile = pkgs.stdenv.mkDerivation rec {
            name = "openrgb-profile";
            src = builtins.path {
                path = ./${profileName};
                name = profileName;
            };

            phases = [ "installPhase" ];

            installPhase = ''
                mkdir -p $out/share
                cp ${src} $out/share/${profileName}
            '';
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
    in mkIf enable {
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
                ExecStart = [ "${openrgbAppimage}/bin/openrgb --profile ${profile}/share/${config.networking.hostName}.orp" ];
            };
        };
    };
}
