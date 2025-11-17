{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.net = {
        # Whether or not to use NetworkManager.
        networkmanager = mkOption {
            type = types.bool;
            default = true;
        };

        # Whether to open port 9 for WakeOnLAN.
        allowWOL = mkOption {
            type = types.bool;
            default = false;
        };

        extraOpenPorts = mkOption {
            type = types.listOf types.int;
            default = if (config.home-manager.users |> builtins.hasAttr "${aeon.user}") then (
                if config.home-manager.users."${aeon.user}".services.syncthing.enable
                # Default listen address (https://docs.syncthing.net/v1.29.3/users/config#listen-addresses)
                # Local announce port (https://docs.syncthing.net/users/config?version=v1.29.5#config-option-options.localannounceport)
                then [ 21027 22000 ]
                else []
            ) else [];
        };
    };

    config = let
        inherit (config.aeon.net) networkmanager allowWOL extraOpenPorts;
        ports.open = if allowWOL then [ 9 ] else [ ];
    in {
        networking = {
            useDHCP = lib.mkDefault true;
            networkmanager.enable = networkmanager;
            firewall = {
                enable = true;
                allowedTCPPorts = ports.open ++ extraOpenPorts;
                allowedUDPPorts = ports.open ++ extraOpenPorts;
            };
        };

        environment = {
            systemPackages = with pkgs; [
                aeon.siren   # My Wake-on-LAN tool written in Rust.
                bandwhich    # Bandwidth utilization tool.
                dig          # CLI DNS client.
                doggo        # CLI DNS client, written in Go (`dig` alternative).
                ethtool      # For controlling network drivers and hardware.
                gping        # `ping`, but with a graph.
                hurl         # Perform HTTP requests defined in plain text.
                iperf3       # Bandwidth profiling tool.
                mtr          # My Traceroute, for debugging random packet loss.
                netdiscover  # Discover hosts in LAN.
                nmap         # Port scanner.
                rustscan     # The "Modern Port Scanner".
                speedtest-rs # CLI internet speedtest tool in Rust.
                wakeonlan    # The original WoL thing.
            ];
        };
    };
}
