{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.kernel = {
        type = mkOption {
            type = types.enum [ "default" "zen" ];
            default = "zen";
            description = "What kind of Linux kernel to use";
        };
    };

    config = mkMerge [
        (mkIf (config.aeon.kernel.type == "zen") {
            boot.kernelPackages = pkgs.linuxPackages_zen;
        })
    ];
}
