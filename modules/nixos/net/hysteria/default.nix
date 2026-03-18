{ pkgs, config, lib, ... }:

{
    options.aeon.net.hysteria = {
        enable = lib.mkEnableOption "hysteria v2 proxy";
    };

    config = let cfg = config.aeon.net.hysteria;
    in lib.mkIf cfg.enable {
        systemd.services."hysteria-client" = {
            description = "Hysteria proxy client";

            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];

            environment.HYSTERIA_LOG_LEVEL = "info";
            serviceConfig = {
                ExecStart = [ "${lib.getExe pkgs.hysteria} client --config ${config.sops.secrets."configs/hysteria/timeweb.yaml".path}" ];
                Restart = "on-failure";
                RestartSec = 5;
            };
        };

        sops.secrets."configs/hysteria/timeweb.yaml" = { };
    };
}
