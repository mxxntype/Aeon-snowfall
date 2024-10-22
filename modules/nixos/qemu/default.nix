# INFO: NixOS QEMU/KVM module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
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
            qemu
            virt-manager
        ];

        # NOTE: Enable kernel support for IOMMU.
        # This is needed for PCI (GPU) passthrough.
        boot.kernelParams = [ "intel_iommu=on" ];
    };
}
