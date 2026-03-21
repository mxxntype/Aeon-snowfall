{ config, lib, ... }:

{
    options.aeon.net.sing-box = {
        enable = lib.mkEnableOption "sing-box modular proxy engine";
    };

    config = let
        cfg = config.aeon.net.sing-box;
        tailscale_ip_ranges = [ "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
        invian_ip_ranges = [ "10.85.0.0/24" "10.129.0.0/24" "84.252.141.155/32" "192.168.85.0/24" "87.117.178.114/32" ];
    in lib.mkIf cfg.enable {
        services.sing-box = {
            enable = true;
            settings = {
                inbounds = [
                    {
                        type = "tun";
                        tag = "tun-in";
                        interface_name = "tun0";
                        auto_route = true;
                        auto_redirect = true;
                        strict_route = true;
                        address = [ "172.19.0.1/30" ];
                        route_exclude_address = tailscale_ip_ranges ++ invian_ip_ranges;
                    }
                ];

                outbounds = [
                    {
                        type = "direct";
                        tag = "direct";
                    }
                    {
                        type = "hysteria2";
                        tag = "out-hysteria2-timeweb-nl0";
                        server = { _secret = config.sops.secrets."keys/hysteria/timeweb-nl0/addr".path; };
                        server_port = 443;
                        password = { _secret = config.sops.secrets."keys/hysteria/timeweb-nl0/auth".path; };
                        tls = {
                            enabled = true;
                            server_name = { _secret = config.sops.secrets."keys/hysteria/timeweb-nl0/sni".path; };
                            certificate_public_key_sha256 = [ "1qKbH9EhgrXEkd3ZvqLoD6JWrOWkC2U1zqScK2Ufj+U=" ];
                        };
                    }
                ];

                route = {
                    auto_detect_interface = true;
                    final = "out-hysteria2-timeweb-nl0";
                    default_domain_resolver = "dns-https-cloudflare";

                    rules = [
                        { action = "sniff"; }
                        { action = "hijack-dns"; protocol = "dns"; }

                        { action = "bypass"; outbound = "direct"; ip_cidr = tailscale_ip_ranges; }
                        { action = "bypass"; outbound = "direct"; ip_cidr = invian_ip_ranges; }

                        { outbound = "direct"; ip_is_private = true; }
                        { outbound = "direct"; domain_suffix = [ "ru" ]; }
                        { outbound = "direct"; rule_set = "geoip-ru"; }

                        { outbound = "direct"; rule_set = "geosite-github"; }
                    ];

                    rule_set = [
                        {
                            tag = "geoip-ru";
                            type = "remote";
                            format = "binary";
                            url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs";
                            download_detour = "out-hysteria2-timeweb-nl0";
                        }
                        {
                            tag = "geosite-github";
                            type = "remote";
                            format = "binary";
                            url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-github.srs";
                            download_detour = "out-hysteria2-timeweb-nl0";
                        }
                    ];
                };

                dns = {
                    final = "dns-https-cloudflare";
                    servers = [
                        {
                            type = "https";
                            tag = "dns-https-cloudflare";
                            server = "1.1.1.1";
                            path = "/dns-query";
                        }
                    ];
                };

                experimental.cache_file.enabled = true;
            };
        };
        
        sops.secrets = {
            "keys/hysteria/timeweb-nl0/addr" = { };
            "keys/hysteria/timeweb-nl0/auth" = { };
            "keys/hysteria/timeweb-nl0/sni" = { };
        };
    };
}
