{ config, lib, ... }:

{
    options.aeon.net.sing-box = {
        enable = lib.mkEnableOption "sing-box modular proxy engine";
    };

    config = let
        cfg = config.aeon.net.sing-box;
        hostname = config.networking.hostName;
    in lib.mkIf cfg.enable {
        services.sing-box = {
            enable = true;
            settings = {
                inbounds = [
                    {
                        listen = "127.0.0.1";
                        listen_port = 1080;
                        tag = "socks-in";
                        type = "socks";
                    }
                    {
                        type = "tun";
                        tag = "tun-in";
                        interface_name = "tun0";
                        auto_route = true;
                        auto_redirect = true;
                        strict_route = true;
                        address = [ "172.19.0.1/30" ];
                        # HACK: Do not let this TUN swallow tailnet traffic
                        route_exclude_address = [
                            "100.64.0.0/10"
                            "fd7a:115c:a1e0::/48"
                        ];
                    }
                ];

                outbounds = [
                    {
                        type = "direct";
                        tag = "direct";
                    }
                    {
                        type = "hysteria2";
                        tag = "out-hysteria2-timeweb";
                        server = { _secret = config.sops.secrets."keys/hysteria/timeweb/addr".path; };
                        server_port = 443;
                        password = { _secret = config.sops.secrets."keys/hysteria/timeweb/auth".path; };
                        tls = {
                            enabled = true;
                            server_name = { _secret = config.sops.secrets."keys/hysteria/timeweb/sni".path; };
                            certificate_public_key_sha256 = [ "1qKbH9EhgrXEkd3ZvqLoD6JWrOWkC2U1zqScK2Ufj+U=" ];
                        };
                    }
                ];

                route = {
                    auto_detect_interface = true;
                    final = "out-hysteria2-timeweb";

                    rules = [
                        { action = "sniff"; }
                        { action = "hijack-dns"; protocol = "dns"; }

                        { action = "bypass"; outbound = "direct"; ip_cidr = [ "100.64.0.0/10" "fd7a:115c:a1e0::/48" ]; }

                        { outbound = "direct"; ip_is_private = true; }
                        { outbound = "direct"; domain_suffix = [ "ru" ]; }
                        { outbound = "direct"; rule_set = "geoip-ru"; }
                    ];

                    rule_set = [{
                        tag = "geoip-ru";
                        type = "remote";
                        format = "binary";
                        url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
                        download_detour = "out-hysteria2-timeweb";
                    }];
                };

                dns = {
                    final = "dns-https-cloudflare";
                    servers = [{
                        type = "https";
                        tag = "dns-https-cloudflare";
                        server = "1.1.1.1";
                        path = "/dns-query";
                    }];
                };

                experimental.cache_file.enabled = true;
            };
        };
        
        sops.secrets = {
            "keys/hysteria/timeweb/addr" = { };
            "keys/hysteria/timeweb/auth" = { };
            "keys/hysteria/timeweb/sni" = { };
            "keys/wireguard/invian0/${hostname}/private_key" = { };
            "keys/wireguard/invian0/${hostname}/addr" = { };
            "keys/wireguard/invian0/${hostname}/peer_addr" = { };
            "keys/wireguard/invian0/${hostname}/peer_public_key" = { };
            "keys/wireguard/invian0/${hostname}/peer_preshared_key" = { };
        };
    };
}
