# INFO: Illusion, a virtual machine.

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
        fs.type = "btrfs";
    };

    disko.devices = {
        disk = {
            vda = {
                type = "disk";
                device = "/dev/vda";
                content = {
                    type = "gpt";
                    partitions = {
                        efi = {
                            priority = 1;
                            name = "NIXOS_EFI";
                            size = "256M";
                            type = "EF00";
                            content = {
                                type = "filesystem";
                                format = "vfat";
                                mountpoint = "/boot/efi";
                            };
                        };

                        root = {
                            name = "NIXOS_ROOT";
                            size = "100%";
                            content = {
                                type = "btrfs";
                                extraArgs = [ "--force" ];
                                subvolumes = let
                                    btrfsOptions = [ "compress=zstd" "space_cache=v2" ];
                                in {
                                    "@" = {
                                        mountpoint = "/";
                                        mountOptions = btrfsOptions;
                                    };
                                    "@home" = {
                                        mountpoint = "/home";
                                        mountOptions = btrfsOptions;
                                    };
                                    "@nix" = {
                                        mountpoint = "/nix";
                                        mountOptions = btrfsOptions ++ [ "noatime" ];
                                    };
                                };
                            };
                        };
                    };
                };
            };
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
