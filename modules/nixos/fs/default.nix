# INFO: Filesystem NixOS module.

{
    # inputs,
    config,
    lib,
    pkgs,
    ...
}:

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

        ephemeral = mkOption {
            type = with types; bool;
            default = false;
            description = "Whether to use ephemeral root storage";
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
            ephemeral
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

            # NOTE: Idk if I want this.
            # services.btrfs.autoScrub = {
            #     enable = mkDefault true;
            #     fileSystems = [ "/" ];
            # };

            # NOTE: This is done by disko.
            # fileSystems = {
            #     "/" = {
            #         device = "/dev/${config.networking.hostName}/root";
            #         options = with mountOptions; common ++ [ "subvol=@" ] ++ btrfs;
            #         fsType = "btrfs";
            #     };
            #
            #     "/home" = {
            #         device = "/dev/${config.networking.hostName}/root";
            #         options = with mountOptions; common ++ [ "subvol=@home" ] ++ btrfs;
            #         fsType = "btrfs";
            #     };
            #
            #     "/nix" = {
            #         device = "/dev/${config.networking.hostName}/root";
            #         options = with mountOptions; common ++ [ "subvol=@nix" "noatime" ] ++ btrfs;
            #         fsType = "btrfs";
            #     };
            # };
        })

        # Ephemeral BTRFS. WARN: WIP, does not work yet!
        #
        # The only example of an ephemeral BTRFS I could find:
        # https://github.com/Misterio77/nix-config/blob/main/hosts/common/optional/ephemeral-btrfs.nix
        (mkIf (type == "btrfs" && ephemeral) {
            boot.initrd.postDeviceCommands = let
                    TEMP_DIR = "/btrfs_tmp";
                    OLD_ROOTS = "old_roots";
                    HOSTNAME = lib.toLower config.networking.hostName;
                in lib.mkAfter /* bash */ ''
                    mkdir ${TEMP_DIR}
                    mount /dev/${HOSTNAME}/root ${TEMP_DIR}
                    if [[ -e ${TEMP_DIR}/root ]]; then
                        mkdir -p ${TEMP_DIR}/${OLD_ROOTS}
                        local TIMESTAMP=$(date --date="@$(stat -c %Y ${TEMP_DIR}/root)" "+%Y-%m-%-d_%H:%M:%S")
                        mv ${TEMP_DIR}/root "${TEMP_DIR}/${OLD_ROOTS}/$TIMESTAMP"
                    fi

                    delete_subvolume_recursively() {
                        local IFS=$'\n'
                        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                            delete_subvolume_recursively "${TEMP_DIR}/$i"
                        done
                        btrfs subvolume delete "$1"
                    }

                    for i in $(find ${TEMP_DIR}/${OLD_ROOTS}/ -maxdepth 1 -mtime +30); do
                        delete_subvolume_recursively "$i"
                    done

                    btrfs subvolume create ${TEMP_DIR}/root
                    umount ${TEMP_DIR}
                '';

            # NOTE: This is also managed by disko.
            # fileSystems = {
            #     ${aeon.persist} = {
            #         device = "/dev/${hostName}/root";
            #         options = with mountOptions; common ++ [ "subvol=@persist" ] ++ btrfs;
            #         fsType = "btrfs";
            #         neededForBoot = true;
            #     };
            # };
        })

        # NOTE: Common ephemeral FS stuff, shamelessly stolen from Misterio77's nix-config.
        # https://github.com/Misterio77/nix-config/blob/main/hosts/common/global/optin-persistence.nix
        (mkIf ephemeral {
            programs.fuse.userAllowOther = true;
            environment.persistence = {
                ${aeon.persist} = {
                    directories = [
                        "/etc/NetworkManager"
                        "/opt"
                        "/var/cache"
                        "/var/lib"
                        "/var/log"
                    ];
                };
            };

            system.activationScripts.persistent-dirs.text = let
                users = attrValues config.users.users;
                mkPersistentHome = user: optionalString user.createHome /* bash */ ''
                    mkdir -p /persist/${user.home}
                    chown ${user.name}:${user.group} /persist/${user.home}
                    chmod ${user.homeMode} /persist/${user.home}
                '';
            in concatLines (map mkPersistentHome users);
        })

        (mkIf (type == "zfs") {
            boot = {
                supportedFilesystems = [ "zfs" ];
                kernelParams = [ "zfs.zfs_arc_max=${toString (cacheLimitGiB * 1024 * 1024 * 1024)}" ];
            };
        })

        # TODO: Ephemeral ZFS.
        #
        # Reading:
        # https://github.com/jordanisaacs/dotfiles/blob/master/modules/system/impermanence/default.nix
        # https://grahamc.com/blog/erase-your-darlings
        # (mkIf (type == "zfs" && ephemeral) { })
    ];
}
