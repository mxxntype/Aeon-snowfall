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

        # encrypted = mkOption {
        #     type = types.bool;
        #     default = true;
        #     description = "Whether to use LUKS2";
        # };
    };

    config = mkMerge [
        {
            boot = {
                tmp.cleanOnBoot = true;            # Clean `/tmp` on boot.
                supportedFilesystems = [ "ntfs" ]; # Support Windows NTFS drives.
            };

            environment.systemPackages = with pkgs; [
                e2fsprogs # Tools for creating and checking ext2/ext3/ext4 filesystems.
                libxfs    # SGI XFS utilities.
            ];

            fileSystems."/".fsType = config.aeon.fs.type;
        }

        (mkIf (config.aeon.fs.type == "btrfs") {
            services.btrfs.autoScrub.enable = mkDefault true;
        })

        # TODO
        (mkIf (config.aeon.fs.type == "zfs") { })

        # TODO
        # (mkIf config.aeon.fs.encrypted { })
    ];
}
