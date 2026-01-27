{ config, lib, pkgs, ... }:

{
    aeon = {
        hardware = {
            autoreboot.enable = true;
            meta.headless = true;
            cpu.type = "intel";
            gpu.intel = {
                enable = true;
                busID = "PCI:0:2:0";
            };

            cups = {
                enable = true;
                drivers = [ pkgs.hplipWithPlugin ];
                server = true;
            };
        };

        boot.type = "uefi";
        fs = {
            type = "zfs";
            cacheLimitGiB = 16;
        };

        net = {
            ssh.server = true;
            tailscale.ACLtags = [ "server" ];
            wireguard.interfaces = { personal.enable = true; };
        };

        docker.enable = true;
        qemu.enable = true;
    };

    disko.devices = let inherit (config.networking) hostName; in {
        disk."system-nvme-ssd" = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S6Z1NU0XA80347V";
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

    services = {
        logrotate.checkConfig = false;
        iperf3 = {
            enable = true;
            openFirewall = true;
        };

        samba = {
            enable = true;
            openFirewall = true;

            settings = {
                global = {
                    "workgroup" = "WORKGROUP";
                    "server min protocol" = "SMB3";
                    "server max protocol" = "SMB3";
                    "security" = "user";
                    "map to guest" = "Never";
                    "vfs objects" = "acl_xattr";
                    "store dos attributes" = "yes";
                };

                share = {
                    "path" = "/mnt/net/win/exoudueux";
                    "browseable" = "yes";
                    "read only" = "no";
                    "guest ok" = "no";
                    "valid users" = "exoudueux-net";
                    "force user" = "exoudueux-net";
                };

                atlas = {
                    "path" = "/mnt/net/win/mxxntype";
                    "browseable" = "yes";
                    "read only" = "no";
                    "guest ok" = "no";
                    "valid users" = "atlas";
                    "force user" = "atlas";
                };
            };
        };

        samba-wsdd = {
            enable = true;
            openFirewall = true;
        };

        avahi = {
            publish.enable = true;
            publish.userServices = true;
            nssmdns4 = true;
            enable = true;
            openFirewall = true;
        };
    };

    users.users.exoudueux-net = {
        isNormalUser = true;
        hashedPassword = "!";
    };

    users.users.atlas = {
        isNormalUser = true;
        hashedPassword = "!";
    };

    networking.firewall.allowedTCPPorts = [ 3000 25565 ];
    networking.firewall.allowedUDPPorts = [ 25565 24454 ];

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = { };
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    boot.zfs.extraPools = let inherit (config.networking) hostName; in [
        "${hostName}-rpool"
        "${hostName}-hdd"
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.grub.enable = lib.mkForce false;

    system.stateVersion = "24.05";  # WARN: Changing this might break things. Just leave it.
    networking.hostId = "2b5004bb"; # Needed for ZFS machine identification.
}
