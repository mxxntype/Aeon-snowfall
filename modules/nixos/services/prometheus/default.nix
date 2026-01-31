{ config, lib, ... }:

{
    options.aeon.services.prometheus = {
        enable = lib.mkEnableOption "Prometheus and node exporter";
    };

    config = let cfg = config.aeon.services.prometheus;
    in lib.mkIf cfg.enable {
        services.prometheus = {
            enable = true;
            listenAddress = "127.0.0.1";

            globalConfig.scrape_interval = "10s";
            scrapeConfigs = [
                {
                    job_name = "node_exporter";
                    static_configs = [
                        { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
                    ];
                }
            ];

            exporters.node = {
                enable = true;
                port = 9000;
                listenAddress = "127.0.0.1";
                enabledCollectors = [
                    "ethtool"
                    "systemd"
                    "tcpstat"
                ];
            };
        };

        services.grafana = {
            enable = true;
            settings = {
                server = {
                    http_addr = "127.0.0.1";
                    http_port = 3000;
                    enforce_domain = false;
                    enable_gzip = true;
                };

                # NOTE: Prevents Grafana from phoning home.
                analytics.reporting_enabled = false;
            };

            provision = {
                datasources.settings.datasources = [
                    {
                        name = "Prometheus";
                        type = "prometheus";
                        url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
                        isDefault = true;
                        editable = false;
                    }
                ];
            };
        };
    };
}
