{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.kernel = {
        type = mkOption {
            type = types.enum [ "default" "zen" ];
            default = "default";
            description = "What kind of Linux kernel to use";
        };
    };

    config = mkMerge [
        (mkIf (config.aeon.kernel.type == "zen") {
            boot.kernelPackages = pkgs.linuxPackages_zen;
        })
    ];
}
