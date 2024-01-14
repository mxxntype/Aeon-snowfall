{
    config,
    ...
}:

{
    aeon = {
        boot = {
            type = "uefi";
            quiet = false;
            grub.device = "/dev/disk/by_label/${config.networking.hostName}_boot";
        };
        fs = {
            type = "btrfs";
            ephemeral = true;
        };
    };

    boot = {
        initrd = {
            kernelModules = [ ];
            availableKernelModules = [ ];
            systemd = {};
        };

        kernelModules = [ ];
        extraModulePackages = [ ];
    };

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
