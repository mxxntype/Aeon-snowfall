{
    ...
}:

{
    aeon = {
        boot = {
            type = "lanzaboote";
            quiet = false;
        };
        fs = {
            type = "btrfs";
            # ephemeral = true;
        };
    };

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = {};
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
