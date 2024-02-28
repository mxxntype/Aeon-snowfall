# INFO: Power management NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.powerManagement = {
        type = mkOption {
            description = "What style of power-management to use";
            type = with types; enum [ "laptop" "desktop" ];
            default = "desktop";
        };

        service = mkOption {
            description = "What service to use for power-management";
            type = with types; enum [ "auto-cpufreq" ];
            default = "auto-cpufreq";
        };
    };

    config = let
        inherit (config.aeon.powerManagement)
            type
            service
            ;
    in mkMerge [
        {
            environment.systemPackages = with pkgs; [ aeon.powerdrain ];
        }

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
            } else {
                # TODO: Desktop profiles.
            };
        })
    ];
}
