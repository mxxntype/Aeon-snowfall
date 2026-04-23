{ config, lib, pkgs, ... }:

with lib; {
    options.aeon.sound = {
        enable = mkOption {
            description = "Whether to enable PipeWire sound system";
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.sound.enable {
        services.pipewire = {
            enable = true;
            wireplumber.enable = true;
            pulse.enable = true;
            jack.enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
        };

        environment.systemPackages = with pkgs; [ alsa-utils aeon.wiremix ];
    };
}
