{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.qemu = {
        enable = mkOption {
            description = "Whether to enable QEMU/KVM virtualisation";
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.qemu.enable {
        virtualisation.libvirtd.enable = true;

        environment.systemPackages = with pkgs; [
            libguestfs # NOTE: Tools for accessing and modifying virtual machine disk images.
            qemu
            virt-manager
        ];

        # HACK: Not sure why, but without this setting, QEMU VMs can't seem to
        # get an IP via DHCP, and I guess can't reach the host networking stack
        # at all for that matter. This fixes it; I have not encountered this
        # issue before on older NixOS versions, perhaps NFtables is to blame.
        networking.firewall.trustedInterfaces = [ "virbr0" ];
    };
}
