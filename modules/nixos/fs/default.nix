# INFO: Filesystem NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.fs = {
        type = mkOption {
            type = types.enum [ "ext4" "btrfs" "zfs" ];
            default = "btrfs";
            description = "Which filesystem to use";
        };

        ephemeral = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use ephemeral root storage";
        };

        ssd = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use SSD-related options";
        };

        # TODO:
        # encrypted = mkOption {
        #     type = types.bool;
        #     default = true;
        #     description = "Whether to use LUKS2 FDE";
        # };
    };

    config = let
        inherit (config.aeon.fs) type ephemeral ssd;
        inherit (config.networking) hostName;
        mountOptions = {
            common = if ssd then [ "ssd" ] else [];
            btrfs = [ "compress=zstd" "space_cache=v2" ];
        };
    in mkMerge [
        # Common FS options that should be used regardless of the filesystem.
        {
            boot = {
                tmp.cleanOnBoot = true;            # Clean `/tmp` on boot.
                supportedFilesystems = [ "ntfs" ]; # Support Windows NTFS drives.
            };

            # Tools for creating and managing uncommon filesystems.
            environment.systemPackages = with pkgs; [
                e2fsprogs # ext2 | ext3 | ext4.
                libxfs    # SGI XFS.
            ];
        }

        # Good old ext4.
        (mkIf (type == "ext4") {
            fileSystems = {
                "/" = {
                    device = mkDefault "/dev/${config.networking.hostName}/root";
                    options = mountOptions.common;
                    fsType = mkForce "ext4";
                };
            };
        })

        # Standard BTRFS.
        #
        # SUBVOLUMES:
        #   NAME   MOUNTPOINT  OPTIONS
        # - @      /           compress=zstd,space_cache=v2
        # - @home  /home       compress=zstd,space_cache=v2
        # - @nix   /nix        compress=zstd,space_cache=v2,noatime
        #
        # NOTE: If BTRFS is in use, likely so is LVM (Yes, I use both together).
        # On UEFI systems, the system drive is usually laid out like this:
        # (Legacy BIOS does not have the EFI partition)
        #
        # NAME             FSTYPE       LABEL            MOUNTPOINTS      | INFO:
        # ...                                                             |
        # nvme0n1                                                         | System drive:
        # ├─nvme0n1p1      vfat         EFI              /boot            |   EFI boot partition.
        # ├─nvme0n1p2      crypto_LUKS  (hostname)_luks                   |   LUKS-encrypted LVM2 PV.
        # │ └─root         LVM2_member  (hostname)                        |   LVM2 VG.
        # │   ├─luna-root  btrfs        (hostname)_root  /                |   LVM2 root LV.
        # │   └─luna-data               (hostname)_data  /mnt/data        |   Other LVM2 LVs.
        # │     ...                                                       |   ...
        # │                                                               |
        # └─nvme0n1p3                   (hostname)_smth  /mnt/smt         |   Non-NixOS partitions.
        #   ...                                                           |   ...
        (mkIf (type == "btrfs") {
            boot.initrd.supportedFilesystems = [ "btrfs" ];
            services.btrfs.autoScrub = {
                enable = mkDefault true;
                fileSystems = [ "/" ];
            };

            fileSystems = {
                "/" = {
                    device = mkDefault "/dev/${config.networking.hostName}/root";
                    options = with mountOptions; common ++ [ "subvol=@" ] ++ btrfs;
                    fsType = mkForce "btrfs";
                };

                "/home" = {
                    device = mkDefault "/dev/${config.networking.hostName}/root";
                    options = with mountOptions; common ++ [ "subvol=@home" ] ++ btrfs;
                    fsType = mkForce "btrfs";
                };

                "/nix" = {
                    device = mkDefault "/dev/${config.networking.hostName}/root";
                    options = with mountOptions; common ++ [ "subvol=@nix" "noatime" ] ++ btrfs;
                    fsType = mkForce "btrfs";
                };
            };
        })

        # Ephemeral BTRFS. WARN: WIP, does not work yet!
        #
        # The only example of an ephemeral BTRFS I coud find:
        # https://github.com/Misterio77/nix-config/blob/main/hosts/common/optional/ephemeral-btrfs.nix
        (mkIf (type == "btrfs" && ephemeral) { 
            boot.initrd = let
                phase1systemd = config.boot.initrd.systemd.enable;
                wipeScript = /* bash */ '' # FIXME
                    mkdir /tmp -p
                    MOUNTPOINT=$(mktemp -d)
                    (
                        mount -t btrfs /dev/${hostName}/root -o subvol=@ "$MOUNTPOINT"
                        trap 'umount "$MOUNTPOINT"' EXIT

                        echo "Creating needed directories"
                        mkdir -p "$MOUNTPOINT"/persist/var/{log,lib/{nixos,systemd}}

                        echo "Cleaning root subvolume"
                        btrfs subvolume list -o "$MOUNTPOINT/root" | cut -f9 -d ' ' |
                        while read -r SUBVOLUME; do
                            btrfs subvolume delete "$MOUNTPOINT/$SUBVOLUME"
                        done && btrfs subvolume delete "$MOUNTPOINT/@"

                        echo "Restoring blank subvolume"
                        btrfs subvolume snapshot "$MOUNTPOINT/root-blank" "$MOUNTPOINT/root"
                    )
                '';
            in {
                supportedFilesystems = [ "btrfs" ];
                postDeviceCommands = mkIf (!phase1systemd) (mkBefore wipeScript);
                systemd.services.restore-root = mkIf phase1systemd {
                    description = "Rollback BTRFS rootfs";
                    # FIXME
                    requires = [ "dev-disk-by\\x2dlabel-${hostName}.device" ];
                    after = [
                        "dev-disk-by\\x2dlabel-${hostName}.device"
                        "systemd-cryptsetup@${hostName}.service"
                    ];

                    before = [ "sysroot.mount" ];
                    wantedBy = [ "initrd.target" ];
                    unitConfig.DefaultDependencies = "no";
                    serviceConfig.Type = "oneshot";
                    script = wipeScript;
                };
            };

            fileSystems = {
                ${aeon.persist} = {
                    device = mkDefault "/dev/${hostName}/root";
                    options = with mountOptions; common ++ [ "subvol=@persist" ] ++ btrfs;
                    neededForBoot = true;
                    fsType = mkForce "btrfs";
                };
            };
        })

        # NOTE: Common ephemeral FS stuff, shamelessly stolen from Misterio77's nix-config.
        # https://github.com/Misterio77/nix-config/blob/main/hosts/common/global/optin-persistence.nix
        (mkIf ephemeral {
            programs.fuse.userAllowOther = true;
            environment.persistence = {
                ${aeon.persist} = {
                    directories = [
                        "/var/lib/systemd"
                        "/var/lib/nixos"
                        "/var/log"
                        "/srv"
                    ];
                };
            };

            system.activationScripts.persistent-dirs.text = let
                users = attrValues config.users.users;
                mkHomePersist = user: optionalString user.createHome /* shell */ ''
                    mkdir -p /persist/${user.home}
                    chown ${user.name}:${user.group} /persist/${user.home}
                    chmod ${user.homeMode} /persist/${user.home}
                '';
            in concatLines (map mkHomePersist users);
        })

        # TODO: Learn ZFS.
        # (mkIf (type == "zfs") { })

        # TODO: Ephemeral ZFS.
        #
        # Reading:
        # https://github.com/jordanisaacs/dotfiles/blob/master/modules/system/impermanence/default.nix
        # https://grahamc.com/blog/erase-your-darlings
        # (mkIf (type == "zfs" && ephemeral) { })

        # TODO: LUKS(2).
        # (mkIf encrypted { })
    ];
}
