# INFO: System-level, containerized Invidious.
# Adapted from https://docs.invidious.io/installation/#docker-compose-method-production

{ lib, config, ... }:

{
    options.aeon.services.invidious = {
        enable = lib.mkEnableOption "local Invidious instance";
        port = lib.mkOption { type = lib.types.int; default = 3000; };
    };

    config = let
        cfg = config.aeon.services.invidious;

        # WARN: It's NOT recommended to use the same key as HMAC key. Generate a new key!
        # This whole thing is localhost-only, so I guess it does not matter much anyway.
        keys = {
            HMAC = "Ke9uwielied1ahcu";
            companion = "caec6ootei4Eihah";
        };

        meta = {
            username = "kemal";
            password = "kemal";
            database = "invidious";
        };
    in lib.mkIf cfg.enable {
        virtualisation.quadlet = {
            pods.invidious.podConfig.publishPorts = [ "127.0.0.1:${toString cfg.port}:3000" ]; 

            containers = let inherit (config.virtualisation.quadlet) pods;
            in {
                invidious-server = {
                    containerConfig = {
                        image = "quay.io/invidious/invidious:latest";
                        pod = pods.invidious.ref;

                        environments = {
                            INVIDIOUS_CONFIG = /* yaml */ ''
                                db:
                                  dbname: ${meta.database}
                                  user: ${meta.username}
                                  password: ${meta.password}
                                  host: localhost
                                  port: 5432
                                check_tables: true
                                invidious_companion:
                                - private_url: "http://localhost:8282/companion"
                                invidious_companion_key: "${keys.companion}"
                                # external_port:
                                # domain:
                                # https_only: false
                                # statistics_enabled: false
                                hmac_key: "${keys.HMAC}"
                            '';
                        };

                        healthCmd = "wget -nv --tries=1 --spider http://127.0.0.1:3000/api/v1/stats || exit 1";
                        healthInterval = "30s";
                        healthTimeout = "5s";
                        healthRetries = 2;
                    };

                    unitConfig = with config.virtualisation.quadlet.containers; {
                        Requires = [ invidious-database.ref "network-online.target" ];
                        After = [ invidious-database.ref "network-online.target" ];
                    };
                };

                invidious-companion.containerConfig = {
                    image = "quay.io/invidious/invidious-companion:latest";
                    pod = pods.invidious.ref;
                    volumes = [ "companioncache:/var/tmp/youtubei.js:rw" ];
                    environments.SERVER_SECRET_KEY = keys.companion;
                    dropCapabilities = [ "ALL" ];
                    readOnly = true;
                    noNewPrivileges = true;
                };

                invidious-database.containerConfig = rec {
                    image = "docker.io/library/postgres:14";
                    pod = pods.invidious.ref;
                    volumes = [ "postgresdata:/var/lib/postgresql/data" ];
                    environments = {
                        POSTGRES_DB = meta.database;
                        POSTGRES_USER = meta.username;
                        POSTGRES_PASSWORD= meta.password;
                    };

                    healthCmd = "pg_isready -U ${environments.POSTGRES_USER} -d ${environments.POSTGRES_DB}";
                };
            };
        };

        # INFO (from the docs, https://docs.invidious.io/installation/#highly-recommended):
        # Because of various issues, Invidious must be restarted often, at least once a day, ideally every hour.
        systemd = {
            services.invidious-restart.serviceConfig = {
                Type = "oneshot";
                ExecStart = "systemctl restart ${config.virtualisation.quadlet.pods.invidious._serviceName}.service";
            };

            timers.invidious-restart = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                    OnBootSec = "3h";
                    OnUnitActiveSec = "3h";
                    Persistent = false;
                };
            };
        };
    };
}
