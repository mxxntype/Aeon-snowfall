# INFO: Power management NixOS module.

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.powerManagement = {
        type = mkOption {
            type = types.enum [ "laptop" "desktop" ];
            default = "desktop";
            description = "What style of power-management to use";
        };

        service = mkOption {
            type = types.enum [ "auto-cpufreq" ];
            default = "auto-cpufreq";
            description = "What service to use for power-management";
        };
    };

    config = let
        inherit (config.aeon.powerManagement) type service;
    in mkMerge [
        (mkIf (service == "auto-cpufreq") {
            services.auto-cpufreq = if (type == "laptop") then {
                enable = true;
                settings = {
                    battery = {
                        governor = "powersave";
                        turbo = "never";
                    };
                    charger = {
                        governor = "ondemand";
                        turbo = "auto";
                    };
                };
            } else {};
        })
    ];
}
