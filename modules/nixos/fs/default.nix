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

        # encrypted = mkOption {
        #     type = types.bool;
        #     default = true;
        #     description = "Whether to use LUKS2";
        # };
    };

    config = let
        inherit (config.aeon.fs) type ephemeral;
        btrfsOptions = [ "compress=zstd" "space_cache=v2" ];
    in mkMerge [
        {
            fileSystems."/".fsType = type;
            boot = {
                tmp.cleanOnBoot = true;            # Clean `/tmp` on boot.
                supportedFilesystems = [ "ntfs" ]; # Support Windows NTFS drives.
            };

            environment.systemPackages = with pkgs; [
                e2fsprogs # Tools for creating and checking ext2/ext3/ext4 filesystems.
                libxfs    # SGI XFS utilities.
            ];
        }

        # Standart BTRFS.
        (mkIf (type == "btrfs") {
            services.btrfs.autoScrub = {
                enable = mkDefault true;
                fileSystems = [ "/" ];
            };

            fileSystems = {
                "/" = {
                    device = "/dev/${config.networking.hostName}/root";
                    options = [ "subvol=@" ] ++ btrfsOptions;
                };
            };
        })

        # Ephemeral BTRFS.
        (mkIf (type == "btrfs" && ephemeral) { 
            boot.initrd.postDeviceCommands = let
                tmpDir = "/btrfs_tmp";
            in lib.mkAfter /* shell */ ''
                mkdir ${tmpDir}
                mount /dev/${config.networking.hostName}/root ${tmpDir}
                if [[ -e ${tmpDir}/root ]]; then
                    mkdir -p ${tmpDir}/old_roots
                    timestamp=$(date --date="@$(stat -c %Y ${tmpDir}/root)" "+%Y-%m-%-d_%H:%M:%S")
                    mv ${tmpDir}/root "${tmpDir}/old_roots/$timestamp"
                fi

                delete_subvolume_recursively() {
                    IFS=$'\n'
                    for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                        delete_subvolume_recursively "${tmpDir}/$i"
                    done
                    btrfs subvolume delete "$1"
                }

                for i in $(find ${tmpDir}/old_roots/ -maxdepth 1 -mtime +30); do
                    delete_subvolume_recursively "$i"
                done

                btrfs subvolume create ${tmpDir}/root
                umount ${tmpDir}
            '';

            fileSystems = {
                ${aeon.persist} = {
                    device = "/dev/${config.networking.hostName}/root";
                    options = [ "subvol=@persist" ] ++ btrfsOptions;
                    neededForBoot = true;
                    fsType = type;
                };

                "/nix" = {
                    device = "/dev/${config.networking.hostName}/root";
                    options = [ "subvol=@nix" ] ++ btrfsOptions;
                    fsType = type;
                };
            };
        })

        # TODO
        # (mkIf (config.aeon.fs.type == "zfs") { })

        # TODO
        # (mkIf config.aeon.fs.encrypted { })
    ];
}
