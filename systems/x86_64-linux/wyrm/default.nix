# INFO: Wyrm, my by-the-desk server.

{
    config,
    lib,
    ...
}:

{
    aeon = {
        boot.type = "uefi";
        fs.type = "btrfs";

        hardware = {
            gpu = {
                intel = {
                    enable = true;
                    busID = "PCI:0:2:0";
                };

                # FIXME: NVIDIA's drivers currently fail to build.
                # nvidia = {
                #     enable = true;
                #     busID = "PCI:1:0:0";
                # };

                specialise = false;
            };

            vfio = {
                enable = true;
                pciIDs = [ "10de:1b80" "10de:10f0" ];
            };
        };

        docker.enable = true;
        qemu.enable = true;
        multipass.enable = true;

        net = {
            tailscale.ACLtags = [ "server" ];
            wireguard.interfaces = {
                personal.enable = true;
                invian.enable = true;
            };
        };
    };

    # TODO:
    # - Learn ZFS;
    # - Nuke the Windows drive;
    # - Figure out a decent ZFS configuration;
    # - Reinstall with ZFS.
    disko.devices = let
        inherit (config.networking) hostName;
        volumeGroups = {
            system = "${lib.toLower hostName}-system";
        };
    in {
        # INFO: The 512G Adata 2.5" SSD.
        disk."system-ssd" = {
            type = "disk";
            device = "/dev/disk/by-id/ata-ADATA_SU800_2I4220038955";
            content = {
                type = "gpt";
                partitions = {
                    ESP = {
                        priority = 1;
                        name = "NIXOS_EFI";
                        size = "512M";
                        type = "EF00";
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                            mountOptions = [ "defaults" ];
                        };
                    };

                    # WARNING: No LUKS encryption is used!
                    root = {
                        priority = 2;
                        size = "100%";
                        content = {
                            type = "lvm_pv";
                            vg = volumeGroups.system;
                        };
                    };
                };
            };
        };

        # INFO: The 1000G WD Blue 3.5" HDD (Slow storage, currently holds old data, thus unused).
        # disk."storage-hdd" = {
        #     type = "disk";
        #     device = "/dev/disk/by-id/ata-WDC_WD10EZEX-22MFCA0_WD-WCC6Y1FX1DZN";
        # };

        # INFO: The 256G Apacer 2.5" SSD. (Windows drive, thus unused)
        # NOTE: Is auto-mounted using raw NixOS options below.
        # disk."windows-ssd" = {
        #     type = "disk";
        #     device = "/dev/disk/by-id/ata-Apacer_AS350_256GB_50F2072706BA00020637";
        # };
        
        lvm_vg."${volumeGroups.system}" = {
            type = "lvm_vg";
            lvs.root = {
                size = "100%FREE";
                content = {
                    type = "btrfs";
                    extraArgs = [ "--force" /* WARN: Forces overwrite of existing filesystem! */ ];
                    subvolumes = let
                        # INFO: https://btrfs.readthedocs.io/en/latest/Administration.html#btrfs-specific-mount-options
                        mountOptions = [ "ssd" "compress=zstd" "space_cache=v2" ];
                    in {
                        "@" = {
                            mountpoint = "/";
                            inherit mountOptions;
                        };
                        "@home" = {
                            mountpoint = "/home";
                            inherit mountOptions;
                        };
                        "@srv" = {
                            mountpoint = "/srv";
                            inherit mountOptions;
                        };
                        "@nix" = {
                            mountpoint = "/nix";
                            # INFO: https://btrfs.readthedocs.io/en/latest/Administration.html#notes-on-generic-mount-options
                            mountOptions = mountOptions ++ [ "noatime" ];
                        };
                        "@swap" = {
                            mountpoint = "/.swapvol";
                            swap.swapfile.size = "20G"; # Host has 16G of RAM, should be enough.
                        };
                    };
                };
            };
        };
    };

    fileSystems."/mnt/windows" = {
        device = "/dev/disk/by-id/ata-Apacer_AS350_256GB_50F2072706BA00020637-part4";
        fsType = "ntfs";
        options = [ "rw" "uid=${toString config.users.users.${lib.aeon.user}.uid}" ];
    };

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = { };
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    system.stateVersion = "24.05";  # WARN: Changing this might break things. Just leave it.
    networking.hostId = "2b5004bb"; # Needed for ZFS machine identification.
}
