# INFO: NixOS LXD module.

{ config, lib, ... }: with lib;

{
    options.aeon.lxd = {
        enable = mkOption {
            description = "Whether to enable LXD/LXC";
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.lxd.enable {
        virtualisation.lxc.enable = true;
        virtualisation.lxd = {
            enable = true;
            recommendedSysctlSettings = true;
        };

        # NOTE: Needed for `lxd` user group permissions.
        users.users.${lib.aeon.user}.extraGroups = [ "lxd" ];

        # NOTE: Required for storage and networking.
        boot.kernelModules = [ "br_netfilter" "veth" ];
        boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = true;
            "net.ipv6.conf.all.forwarding" = true;
        };

        # NOTE: ZFS support (optional but recommended for storage).
        boot.supportedFilesystems = [ "zfs" ];
    };
}
