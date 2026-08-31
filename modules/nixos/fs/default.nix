{ config, lib, pkgs, ... }:

with lib; {
    options.aeon.fs = {
        type = mkOption {
            type = with types; nullOr (enum [
                "btrfs"
                "zfs"
            ]);
            default = null;
            description = "Which filesystem to use";
        };

        # Mainly a limiter for ZFS's ARC.
        cacheLimitGiB = mkOption {
            type = types.nullOr types.int;
            default = null;
        };
    };

    config = let
        inherit (config.aeon.fs)
            type
            cacheLimitGiB
            ;
    in mkMerge [
        # Common FS options that should be used regardless of the filesystem.
        {
            boot = {
                tmp.cleanOnBoot = true;
                supportedFilesystems = {
                    ntfs = true;
                    zfs = true;
                };
            };

            # Tools for creating and managing uncommon filesystems.
            environment.systemPackages = with pkgs; [
                e2fsprogs # ext2 | ext3 | ext4.
                libxfs    # SGI XFS.
                zfs       # OpenZFS.
                disko
            ];
        }

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
        })

        (mkIf (type == "zfs") {
            boot = {
                zfs.forceImportRoot = false;
                supportedFilesystems = [ "zfs" ];
                kernelParams = [ "zfs.zfs_arc_max=${toString (cacheLimitGiB * 1024 * 1024 * 1024)}" ];
            };
        })
    ];
}
