{ inputs, config, pkgs, lib, ... }:

{
    options.aeon.proxmox = {
        enable = lib.mkEnableOption "Proxmox VE";
        IP = lib.mkOption { type = lib.types.str; }; # WARN: This bitch here must resolve to a nodename.
    };

    config = let cfg = config.aeon.proxmox;
    in lib.mkIf cfg.enable {
        nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.${pkgs.stdenv.hostPlatform.system} ];
        
        boot.kernelModules = [ "br_netfilter" "veth" ];
        boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = true;
            "net.ipv6.conf.all.forwarding" = true;
        };

        services.proxmox-ve = {
            enable = true;
            ipAddress = cfg.IP; 
            bridges = [ "vmbr0" ];
        };

        networking = {
            bridges."vmbr0".interfaces = [ ];

            interfaces.vmbr0.ipv4.addresses = [
                { address = "10.50.0.1"; prefixLength = 24; }
            ];

            firewall.trustedInterfaces = [ "vmbr0" ];

            nat = {
                enable = true;
                # externalInterface = "enp0s31f6";
                internalInterfaces = [ "vmbr0" ];
            };
        };

        systemd.network.networks."vmbr0" = {
            matchConfig.Name = "vmbr0";

            networkConfig = {
                DHCPServer = true;
                IPForward = true;
            };

            dhcpServerConfig = {
                PoolOffset = 100;
                PoolSize = 100;
                DefaultLeaseTimeSec = 3600;
                MaxLeaseTimeSec = 7200;
                DNS = [ "1.1.1.1" "8.8.8.8" ];
            };
        };
    };
}
