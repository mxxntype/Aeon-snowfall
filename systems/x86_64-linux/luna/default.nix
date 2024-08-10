# INFO: Luna, my laptop.

{
    config,
    lib,
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

        hardware.gpu = {
            intel = {
                enable = true;
                busID = "PCI:0:2:0";
            };

            nvidia = {
                enable = true;
                busID = "PCI:1:0:0";
            };

            specialise = true;
        };

        gaming.enable = true;
        services.whoogle.enable = true;
        net.tailscale.ACLtags = [ "client" ];
    };

    disko.devices = let
        inherit (config.networking) hostName;
    in {
        disk."system-nvme-ssd" = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-Micron_2450_MTFDKBA1T0TFK_232140BFC1B2";
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
                            mountpoint = "/boot";
                        };
                    };

                    luks = {
                        size = "100%";
                        content = {
                            type = "luks";
                            name = "${lib.toUpper hostName}_LUKS";
                            settings.allowDiscards = true;
                            content = {
                                type = "lvm_pv";
                                vg = "${lib.toLower hostName}";
                            };
                        };
                    };
                };
            };
        };
        
        lvm_vg."${lib.toLower hostName}" = {
            type = "lvm_vg";
            lvs.root = {
                size = "100%FREE";
                content = {
                    type = "btrfs";
                    extraArgs = [ "--force" ];
                    subvolumes = let
                        mountOptions = [ "compress=zstd" "space_cache=v2" ];
                    in {
                        "@" = {
                            mountpoint = "/";
                            inherit mountOptions;
                        };
                        "@home" = {
                            mountpoint = "/home";
                            inherit mountOptions;
                        };
                        "@nix" = {
                            mountpoint = "/nix";
                            mountOptions = mountOptions ++ [ "noatime" ];
                        };
                    };
                };
            };
        };
    };

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = { };
    boot.initrd.kernelModules = [ ];
    boot.initrd.availableKernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
