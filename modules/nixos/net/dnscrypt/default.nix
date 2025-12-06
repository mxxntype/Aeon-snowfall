# INFO: DNCrypt-proxy2 NixOS module.

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.net.dnscrypt-proxy = {
        enable = mkOption {
            description = "Whether to enable the dnscrypt-proxy2 service";
            type = types.bool;
            default = true;
        };

        settings = mkOption {
            type = types.attrs;
            default = {
                ipv4_servers = true;
                ipv6_servers = true;
                dnscrypt_servers = true;
                doh_servers = true;
                require_dnssec = true;
                require_nolog = true;
                require_nofilter = true;
                block_ipv6 = false;

                timeout = 5000;
                keepalive = 30;
                lb_strategy = "p2";
                lb_estimator = true;
                cache = true;
                force_tcp = false; # No effect if tor is not in use

                bootstrap_resolvers = [ "1.1.1.1:53" ];
                netprobe_address = "1.1.1.1:53";
                captive_portals.map_file = "/etc/dnscrypt-proxy/captive_portals.txt";
            };
        };
    };

    config = let
        inherit (config.aeon.net.dnscrypt-proxy) enable settings;
    in mkIf enable {
        services.dnscrypt-proxy = {
            enable = true;
            upstreamDefaults = true;
            inherit settings;
        };
    };
}
