{ pkgs, config, lib, ... }:

{
    options.aeon.net.sing-box = {
        enable = lib.mkEnableOption "sing-box modular proxy engine";
    };

    config = let cfg = config.aeon.net.sing-box;
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

                endpoints = [
                    {
                        type = "wireguard";
                        tag = "wg-ep-invian0";
                        system = true;
                        address = { _secret = config.sops.secrets."keys/wireguard/invian0/${config.networking.hostName}/addr".path; };
                        private_key = { _secret = config.sops.secrets."keys/wireguard/invian0/${config.networking.hostName}/private_key".path; };
                        peers = [{
                           address        = { _secret = config.sops.secrets."keys/wireguard/invian0/${config.networking.hostName}/peer_addr".path; }; 
                           port           = 51820; 
                           public_key     = { _secret = config.sops.secrets."keys/wireguard/invian0/${config.networking.hostName}/peer_public_key".path; }; 
                           pre_shared_key = { _secret = config.sops.secrets."keys/wireguard/invian0/${config.networking.hostName}/peer_preshared_key".path; }; 
                           allowed_ips    = [ "0.0.0.0/0" ]; 
                           persistent_keepalive_interval = 25;
                        }];
                    }
                ];

                route = {
                    auto_detect_interface = true;
                    final = "out-hysteria2-timeweb";
                    rules = [
                        { action = "sniff"; }
                        { action = "hijack-dns"; protocol = "dns"; }
                        { outbound = "direct"; ip_is_private = true; }
                        { outbound = "direct"; domain_suffix = [ ".ru" ]; }
                        { outbound = "direct"; rule_set = "geoip-ru"; }

                        { outbound = "wg-ep-invian0"; ip_cidr = [ "10.85.0.0/24" "10.129.0.0/24" "84.252.141.155" "192.168.85.0/24" ]; }
                    ];

                    rule_set = [
                        {
                            tag = "geoip-ru";
                            type = "local";
                            format = "binary";
                            path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-ru.srs";
                        }
                    ];
                };

                dns = {
                    final = "dns-https-cloudflare";
                    servers = [
                        # {
                        #     type = "local";
                        #     tag = "dns-local";
                        # }
                        {
                            type = "https";
                            tag = "dns-https-cloudflare";
                            server = "1.1.1.1";
                        }
                    ];
                };
            };
        };

        sops.secrets = {
            "keys/hysteria/timeweb/addr" = { };
            "keys/hysteria/timeweb/auth" = { };
            "keys/hysteria/timeweb/sni" = { };
            "keys/wireguard/invian0/${config.networking.hostName}/private_key" = { };
            "keys/wireguard/invian0/${config.networking.hostName}/addr" = { };
            "keys/wireguard/invian0/${config.networking.hostName}/peer_addr" = { };
            "keys/wireguard/invian0/${config.networking.hostName}/peer_public_key" = { };
            "keys/wireguard/invian0/${config.networking.hostName}/peer_preshared_key" = { };
        };
    };
}
