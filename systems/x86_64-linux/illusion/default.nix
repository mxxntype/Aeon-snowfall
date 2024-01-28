{
    ...
}:

{
    aeon = {
        boot = {
            type = "lanzaboote";
            quiet = true;
            encrypted = true;
        };
        fs = {
            type = "btrfs";
            # ephemeral = true;
        };
    };

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = {};
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
