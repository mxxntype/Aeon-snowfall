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

        {
            environment.systemPackages = [(pkgs.nuenv.writeScriptBin {
                name = "powerdrain";
                script = /* nu */ ''
                    const bat: string = "/sys/class/power_supply/BAT0"
                    const K: int = 1000000000000

                    if ($bat | path exists) {
                        let current: int = (open $"($bat)/current_now" | into int)
                        let voltage: int = (open $"($bat)/voltage_now" | into int)
                        let power: int = ($current * $voltage / $K)
                        $power | into int
                    } else { "N/A" }
                '';
            })];
        }
    ];
}
