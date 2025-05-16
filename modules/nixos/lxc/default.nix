# INFO: NixOS LXC module, also provides support for LXD/Incus.

{ config, lib, ... }: with lib;

{
    options.aeon.lxc = {
        lxd.enable = mkOption {
            description = "Whether to enable LXD";
            type = with types; bool;
            default = false;
        };

        incus.enable = mkOption {
            description = "Whether to enable Incus";
            type = with types; bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.lxc)
            lxd
            incus
            ;
    in mkMerge [
        (mkIf (lxd.enable || incus.enable) {
            virtualisation.lxc.enable = true;
        
            # Required for storage and networking.
            boot.kernelModules = [ "br_netfilter" "veth" ];
            boot.kernel.sysctl = {
                "net.ipv4.ip_forward" = true;
                "net.ipv6.conf.all.forwarding" = true;
            };

            # ZFS support (optional but recommended for storage).
            boot.supportedFilesystems = [ "zfs" ];
        })

        (mkIf lxd.enable {
            virtualisation.lxd = {
                enable = true;
                recommendedSysctlSettings = true;
            };

            # NOTE: Needed for `lxd` user group permissions.
            users.users.${lib.aeon.user}.extraGroups = [ "lxd" ];

        })

        (mkIf incus.enable {
            virtualisation.incus = {
                enable = true;
            };

            networking = {
                # Incus on NixOS is unsupported using iptables.
                nftables.enable = true;
                # Guests can't get addresses via DHCP without this.
                firewall.trustedInterfaces = [ "incusbr0" "incusbr-1000" ];
            };

            # NOTE: Needed for `incus` user group permissions.
            users.users.${lib.aeon.user}.extraGroups = [ "incus" ];
        })
    ];

}
