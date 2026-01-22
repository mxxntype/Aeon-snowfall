{ config, lib, pkgs, ... }:

{
    aeon = {
        hardware = {
            meta.headless = false;

            cpu.type = "amd";
            gpu = {
                amd =    { enable = true; busID = "PCI:79:0:0"; };
                nvidia = { enable = true; busID = "PCI:1:0:0";  };
                # specialise = false;
            };

            vfio = {
                enable = true;
                specialize = true;
                pciIDs = [ "10de:1b80" "10de:10f0" ];
            };

            cups = {
                enable = true;
                drivers = [ pkgs.hplipWithPlugin ];
                client = true;
            };
            
            openrgb = {
                enable = true;
                color = "f8ae54";
                resizeableZones = {
                    device_id = 0;
                    zone_ids = [1 2 3];
                    size = 20;
                };
            };

            bluetooth.enable = true;
            adb.enable = true;

            probe-rs.udev-rules.enable = true;
        };

        boot.type = "uefi";
        fs = { type = "zfs"; cacheLimitGiB = 16; };

        net = {
            ssh.server = true;
            tailscale.ACLtags = [ "client" ];
            wireguard.interfaces = {
                personal.enable = true;
                invian.enable = true;
            };
        };

        services.invidious.enable = true;

        sound.enable = true;
        docker.enable = true;
        qemu.enable = true;
    };

    disko.devices = let inherit (config.networking) hostName; in {
        disk."system-nvme-ssd" = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7HDNF0Y534030P";
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

                    root = {
                        priority = 2;
                        size = "100%";
                        content = {
                            type = "zfs";
                            pool = "${hostName}-rpool";
                        };
                    };
                };
            };
        };
       
        zpool."${hostName}-rpool" = {
            type = "zpool";
            mode = "";         # No mirroring, no RAID.
            mountpoint = null; # Use the dedicated root dataset (see below).

            # NOTE: These are ZPOOL-level properties, see man zpoolprops for more.
            # Since the underlying VDEV is a modern NVMe SSD, TRIM is good for it.
            options.autotrim = "on";

            rootFsOptions = {
                mountpoint = "none";
                acltype = "posixacl";
                atime = "off";
                compression = "zstd";
                "com.sun:auto-snapshot" = "false";
            };

            datasets = let
                # INFO: A small shortcut for creating legacy-mounted
                # datasets without repeating yourself like 10 times.
                legacy = dataset: (lib.recursiveUpdate dataset {
                    type = "zfs_fs";
                    options.mountpoint = "legacy";
                });

                # WARN: Though datasets can be (and some are) defined here,
                # within Nix, ZFS has its own mounting subsystem, which makes
                # more datasets and ZVOLs can be created later, without any
                # modifications to this section. Stuff that I consider vital
                # configuration is listed here, stuff that I consider state
                # (like rootfs ZVOLs for VMs) are created outside of Nix.
            in {
                root = legacy { mountpoint = "/"; };
                nix = legacy { mountpoint = "/nix"; };

                "var/cache" = legacy {
                    mountpoint = "/var/cache";
                    options.compression = "off";
                };

                "var/log" = legacy {
                    mountpoint = "/var/log";
                    options.compression = "lz4";
                };

                srv = legacy { mountpoint = "/srv"; };
                opt = legacy { mountpoint = "/opt"; };

                home = legacy {
                    mountpoint = "/home";
                    options.atime = "on";
                };
            };
        };
    };

    # HACK: This allows sops-nix to read the file during stage 2,
    # however its probably more correct to move the keyfile itself.
    fileSystems."/home".neededForBoot = true;

    specialisation."AtlasOS-VFIO-autoboot".configuration = {
        system.nixos.tags = [ "vfio" ];

        boot.blacklistedKernelModules = [
            "nouveau"
            "nvidia"
            "nvidia_drm"
            "nvidia_modeset"
        ];
        
        systemd.services."atlasOS-autostart" = {
            description = "atlasOS VM autostart service";
            requires = [ "libvirtd.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = [ "${pkgs.libvirt}/bin/virsh start atlasOS_win11" ];
            };
        };
    };

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = { };
    boot.initrd.kernelModules = [ ];
    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid"];
    boot.kernelModules = [ "kvm-amd" "i2c-dev" "i2c-piix4" ];
    boot.extraModulePackages = [ ];
    boot.blacklistedKernelModules = [ "amdgpu" ];

    boot.zfs.extraPools = [ "${config.networking.hostName}-rpool" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.grub.enable = lib.mkForce false;

    system.stateVersion = "25.05";  # WARN: Changing this might break things. Just leave it.
    networking.hostId = "29b414eb"; # Needed for ZFS machine identification.
}
