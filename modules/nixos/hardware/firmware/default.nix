{ config, lib, ... }:

with lib; {
    options.aeon.hardware = {
        firmware = mkOption {
            type = with types; enum [ "free" "redistributable" "all" ];
            default = "redistributable";
        };
    };

    config = let
        inherit (config.aeon.hardware)
            firmware
            cpu
            ;
    in mkMerge [
        (mkIf (firmware == "redistributable") {
            hardware.enableRedistributableFirmware = true;
        })

        (mkIf (firmware == "all") {
            hardware.enableAllFirmware = true;
        })

        (mkIf (firmware == "redistributable" || firmware == "all") {
            hardware = {
                cpu = {
                    amd.updateMicrocode = cpu.type == "amd";
                    intel.updateMicrocode = cpu.type == "intel";
                };
            };
        })
    ];
}
