# INFO: NixOS PipeWire module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.sound = {
        enable = mkOption {
            description = "Whether to enable PipeWire sound system";
            type = with types; bool;
            default = false;
        };
    };

    config = mkIf config.aeon.sound.enable {
        # HACK: https://nixos.wiki/wiki/PipeWire
        sound.enable = false;

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

        # TODO: maybe add `pamixer` for easy volume control.
        environment.systemPackages = with pkgs; [ alsaUtils ];
    };
}
