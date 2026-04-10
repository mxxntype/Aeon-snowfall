{ config, lib, ... }:

{
    options.aeon.net.sing-box = {
        enable = lib.mkEnableOption "sing-box modular proxy engine";
    };

    config = let
        cfg = config.aeon.net.sing-box;
        inherit (config.networking) hostName;
        inherit (config.sops) secrets;
        create_remote_geo_rule_set = { type, name, detour ? "out-hysteria2-timeweb-nl0" }: {
            tag = "geo${type}-${name}";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/SagerNet/sing-geo${type}/rule-set/geo${type}-${name}.srs";
            download_detour = detour;
        };

        tailscale_ip_ranges = [ "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
        invian_ip_ranges = [ "10.85.0.0/24" "10.129.0.0/24" "84.252.141.155/32" "192.168.85.0/24" "87.117.178.114/32" ];
        bypass_ip_ranges = [ ]
            ++ (lib.optionals config.services.tailscale.enable tailscale_ip_ranges)
            ++ (lib.optionals config.aeon.net.wireguard.interfaces.invian0.enable invian_ip_ranges);
    in lib.mkIf cfg.enable {
        services.sing-box = {
            enable = true;
            settings = {
                inbounds = [ {
                    type = "tun";
                    tag = "tun-in";
                    interface_name = "tun0";
                    auto_route = true;
                    auto_redirect = true;
                    strict_route = true;
                    address = [ "172.19.0.1/30" ];
                    route_exclude_address = [ "127.0.0.0/8" "::1/128" ] ++ bypass_ip_ranges;
                } ];

                outbounds = [
                    {
                        type = "direct";
                        tag = "direct";
                    }
                    {
                        type = "hysteria2";
                        tag = "out-hysteria2-timeweb-nl0";
                        server = { _secret = secrets."keys/hysteria/timeweb-nl0/addr".path; };
                        server_port = 443;
                        password = { _secret = secrets."keys/hysteria/timeweb-nl0/auth".path; };
                        tls = {
                            enabled = true;
                            server_name = { _secret = secrets."keys/hysteria/timeweb-nl0/sni".path; };
                            certificate_public_key_sha256 = [ "1qKbH9EhgrXEkd3ZvqLoD6JWrOWkC2U1zqScK2Ufj+U=" ];
                        };
                    }
                ];

                endpoints = [ {
                    type        = "wireguard";
                    tag         = "wg-ep-timeweb-nl0";
                    system      = false;
                    name        = "wg-ep-timeweb-nl0";
                    address     = { _secret = secrets."keys/wireguard/timeweb-nl0/${hostName}/interface_addr".path; } ;
                    private_key = { _secret = secrets."keys/wireguard/timeweb-nl0/${hostName}/interface_private_key".path; };
                    peers = [ {
                        address        = { _secret = secrets."keys/wireguard/timeweb-nl0/${hostName}/peer_endpoint_addr".path; };
                        port           = 51820;
                        public_key     = { _secret = secrets."keys/wireguard/timeweb-nl0/${hostName}/peer_public_key".path; };
                        pre_shared_key = { _secret = secrets."keys/wireguard/timeweb-nl0/${hostName}/peer_preshared_key".path; };
                        allowed_ips    = [ "0.0.0.0/0" ];
                    } ];
                } ];

                route = {
                    auto_detect_interface = true;
                    final = "out-hysteria2-timeweb-nl0";
                    default_domain_resolver = "dns-https-cloudflare";

                    rules = [
                        # HACK: NTP does not seem to work through Hysteria2.
                        { action = "bypass"; outbound = "direct"; network = "udp"; port = 123; }

                        { action = "sniff"; }
                        { action = "hijack-dns"; protocol = "dns"; }

                        { outbound = "out-hysteria2-timeweb-nl0"; domain = "api-fns.ru"; }

                        { outbound = "wg-ep-timeweb-nl0"; rule_set = "geosite-discord"; }

                        { action = "bypass"; outbound = "direct"; ip_cidr = bypass_ip_ranges; }

                        { outbound = "direct"; ip_is_private = true; }
                        { outbound = "direct"; domain_suffix = [ "ru" ]; }
                        { outbound = "direct"; domain_suffix = [ "ntp.org" ]; }
                        { outbound = "direct"; rule_set = "geoip-ru"; }

                        { outbound = "direct"; rule_set = "geosite-github"; }
                    ];

                    rule_set = [
                        (create_remote_geo_rule_set { type = "ip"; name = "ru"; })
                        (create_remote_geo_rule_set { type = "site"; name = "github"; })
                        (create_remote_geo_rule_set { type = "site"; name = "discord"; })
                    ];
                };

                dns = {
                    final = "dns-https-cloudflare";
                    servers = [ {
                        type = "https";
                        tag = "dns-https-cloudflare";
                        server = "1.1.1.1";
                        path = "/dns-query";
                    } ];
                };

                experimental.cache_file.enabled = true;
            };
        };
        
        sops.secrets = {
            "keys/hysteria/timeweb-nl0/addr" = { };
            "keys/hysteria/timeweb-nl0/auth" = { };
            "keys/hysteria/timeweb-nl0/sni" = { };
            "keys/wireguard/timeweb-nl0/${hostName}/interface_addr" = { };
            "keys/wireguard/timeweb-nl0/${hostName}/interface_private_key" = { };
            "keys/wireguard/timeweb-nl0/${hostName}/peer_endpoint_addr" = { };
            "keys/wireguard/timeweb-nl0/${hostName}/peer_public_key" = { };
            "keys/wireguard/timeweb-nl0/${hostName}/peer_preshared_key" = { };
        };
    };
}
