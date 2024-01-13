{
    ...
}:

{
    aeon = {
        fs = {
            type = "btrfs";
            ephemeral = true;
        };
        boot = {
            type = "bios";
            quiet = false;
            grub.device = "/dev/vda";
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
