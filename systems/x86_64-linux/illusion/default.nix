{
    ...
}:

{
    aeon = {
        boot = {
            quiet = false;
        };
        fs = {
            type = "btrfs";
            # ephemeral = true;
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
