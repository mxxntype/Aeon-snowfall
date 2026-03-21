{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.net.wireguard = {
        # TODO: Rework as a list.
        interfaces = {
            timeweb-nl0.enable = mkOption { type = with types; bool; default = false; };
            invian0.enable = mkOption { type = with types; bool; default = false; };
        };

        port = mkOption {
            type = with types; int;
            default = 51820;
        };
    };

    config = let
        hostname = toLower config.networking.hostName;
        inherit (config.aeon.net.wireguard)
            interfaces
            port
            ;
        inherit (interfaces)
            timeweb-nl0
            invian0
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
            tailscale = config.services.tailscale.enable;
        in {
            networking.wg-quick.interfaces."${name}" = {
                configFile = config.sops.secrets."configs/wireguard/${name}".path;
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

            sops.secrets."configs/wireguard/${name}" = { };
        };

    in mkMerge [
        (mkIf enable { networking.firewall.allowedUDPPorts = [ port ]; })
        (mkIf timeweb-nl0.enable (mkTailscaleAwareInterface { inherit config; name = "timeweb-nl0"; }))
        (mkIf invian0.enable (mkTailscaleAwareInterface { inherit config; name = "invian0"; }))
    ];
}
