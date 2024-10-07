{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.net.wireguard = {
        enable = mkOption {
            type = with types; bool;
            default = false;
            description = "Whether to configure a private WireGuard VPN";
        };

        interface = mkOption {
            type = with types; str;
            default = "wg0";
        };

        port = mkOption {
            type = with types; int;
            default = 51820;
        };
    };

    config = let
        hostname = toLower config.networking.hostName;
        tailscale = config.services.tailscale.enable;
        inherit (config.aeon.net.wireguard)
            enable
            interface
            port
            ;
    in mkIf enable {
        networking = {
            firewall.allowedUDPPorts = [ port ];
            wg-quick = {
                interfaces."${interface}" = {
                    configFile = config.sops.secrets."keys/wireguard/default/${hostname}".path;
                    autostart = false;

                    # When a WireGuard VPN starts (the one configured above), Tailscale's DNS settings remain,
                    # but are no longer valid (I think...). Either way, DNS stops working. So for now the fix
                    # is to shutdown Tailscale when a VPN is active, and start it again once the VPN is off.
                    postUp = mkIf tailscale /* shell */ ''
                        ${pkgs.tailscale}/bin/tailscale down
                    '';
                    preDown = mkIf tailscale /* shell */ ''
                        ${pkgs.tailscale}/bin/tailscale up
                    '';
                };
            };
        };

        # NOTE: Only make the *.conf file appear if it's used.
        sops.secrets = mkIf enable {
            "keys/wireguard/default/${hostname}" = { };
        };
    };
}
