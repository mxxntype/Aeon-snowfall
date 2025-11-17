{ config, pkgs, lib, ... }:

{
    options.aeon.hardware.autoreboot = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = config.aeon.hardware.meta.headless;
        };

        run-at = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ "06:00" ];
        };
    };

    config = let
        cfg = config.aeon.hardware.autoreboot;
    in lib.mkIf cfg.enable {
        systemd = {
            services.autoreboot = {
                serviceConfig = {
                    Type = "oneshot";
                    ExecStart = [
                        "${lib.getExe pkgs.aeon.aeon} wait-idle" 
                        "${pkgs.coreutils}/bin/sync"
                        "${pkgs.systemd}/bin/systemctl reboot"
                    ];
                };
            };

            timers.autoreboot = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                    OnCalendar = cfg.run-at;
                    Persistent = false;
                };
            };
        };
    };
}
