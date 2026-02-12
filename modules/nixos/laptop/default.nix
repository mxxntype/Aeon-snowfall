{ config, lib, ... }:

{
    config = let cfg = config.aeon.hardware.meta;
    in lib.mkIf cfg.laptop {
        # INFO: An amazing brightness control tool.
        hardware.brillo.enable = true;

        powerManagement.powertop.enable = true;
        services = {
            power-profiles-daemon.enable = false;
            tlp = {
                enable = true;
                settings = {
                    CPU_BOOST_ON_AC = 0;
                    CPU_BOOST_ON_BAT = 0;
                    CPU_SCALING_GOVERNOR_ON_AC = "performance";
                    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
                    STOP_CHARGE_THRESH_BAT0 = 95;
                };
            };
        };
    };
}
