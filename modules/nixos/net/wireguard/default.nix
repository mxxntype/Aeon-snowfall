{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.net.wireguard = {
        interfaces = {
            personal.enable = mkOption { type = with types; bool; default = false; };
            invian.enable = mkOption { type = with types; bool; default = false; };
        };

        port = mkOption {
            type = with types; int;
            default = 51820;
        };
    };

    config = let
        inherit (config.aeon.net.wireguard)
            interfaces
            port
            ;
        inherit (interfaces)
            personal
            invian
            ;

        # Will be `true` if any of the interfaces are enabled, `false` otherwise.
        enable = interfaces
            |> builtins.attrValues
            |> builtins.map (interface: interface.enable)
            |> builtins.any (enabled: enabled);

        # NOTE: This function returns a NixOS configuration module that will:
        # - Fetch the decrtypted Wireguard config file from sops;
        # - Configure a `wg-quick` interaface using that configuration file;
        # - Ensure that only that interface OR tailscale are active at the same time.
        mkTailscaleAwareInterface = {
            name,
            config,
            autostart ? false
        }: let
            hostname = toLower config.networking.hostName;
            tailscale = config.services.tailscale.enable;
        in {
            networking.wg-quick.interfaces."${name}" = {
                configFile = config.sops.secrets."keys/wireguard/${name}/${hostname}".path;
                inherit autostart;
            };

            # HACK: `networking.wg-quick` has options for this, but they kinda
            # just don't work for me. Setting the same logic here works though.
            systemd.services."wg-quick-${name}" = {
                # When a WireGuard VPN starts (the one configured above), Tailscale's DNS settings remain,
                # but are no longer valid (I think...). Either way, DNS stops working. So for now the fix
                # is to shutdown Tailscale when a VPN is active, and start it again once the VPN is off.
                postStart = mkIf tailscale ''
                    ${pkgs.tailscale}/bin/tailscale down
                '';
                preStop = mkIf tailscale ''
                    ${pkgs.tailscale}/bin/tailscale up
                '';
            };

            sops.secrets."keys/wireguard/${name}/${hostname}" = { };
        };

    in mkMerge [
        (mkIf enable { networking.firewall.allowedUDPPorts = [ port ]; })
        (mkIf personal.enable (mkTailscaleAwareInterface { inherit config; name = "personal"; }))
        (mkIf invian.enable (mkTailscaleAwareInterface { inherit config; name = "invian"; }))
    ];
}
