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

    # NOTE: Flattened for the installer script.
    boot.initrd.systemd = {};
    boot.initrd.kernelModules = [ ];
    boot.initrd.availableKernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
