{ config, lib, ... }:

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
                    # {
                    #     type = "tun";
                    #     tag = "tun-in";
                    #     interface_name = "tun0";
                    #     auto_route = true;
                    #     strict_route = true;
                    #     address = [ "172.19.0.1/30" ];
                    # }
                ];

                outbounds = [
                    {
                        type = "direct";
                        tag = "direct";
                    }
                    {
                        type = "hysteria2";
                        tag = "hy2-out";
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
                    final = "hy2-out";
                    rules = [
                        {
                            outbound = "direct";
                            ip_cidr = [
                                "127.0.0.0/8"
                                "10.0.0.0/8"
                                "172.16.0.0/12"
                                "192.168.0.0/16"
                            ];
                        }

                        { outbound = "direct"; domain_suffix = [ ".ru" ]; }
                    ];
                };

                # dns = {
                #     servers = [
                #         {
                #             type = "dhcp";
                #             tag = "dns-dhcp";
                #         }
                #     ];
                # };
            };
        };

        sops.secrets = {
            "keys/hysteria/timeweb/addr" = { };
            "keys/hysteria/timeweb/auth" = { };
            "keys/hysteria/timeweb/sni" = { };
        };
    };
}
