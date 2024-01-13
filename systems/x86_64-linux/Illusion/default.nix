{
    config,
    ...
}:

{
    aeon = {
        boot.quiet = true;
    };

    # FIXME TODO: Move to a `fs` module.
    fileSystems = {
        "/" = { device = "/dev/sda2"; };
        ${config.boot.loader.efi.efiSysMountPoint} = { device = "/dev/sda1"; };
    };

    boot = {
        initrd = {
            kernelModules = [ ];
            availableKernelModules = [ ];
            systemd = {};
        };

        kernelModules = [ ];
        extraModulePackages = [ ];

        # TODO: Move to a `boot` module.
        loader = {
            grub = {
                device = "nodev";
            };
        };
    };

    system.stateVersion = "23.11"; # WARN: Changing this might break things. Just leave it.
}
