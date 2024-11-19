# INFO: Linux console/TTY NixOS module.

{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:

with lib; {
    options.aeon.console = {
        enable = mkOption {
            description = "Whether to configure the Linux TTY";
            type = types.bool;
            default = true;
        };
    };

    config = mkMerge [
        (mkIf config.aeon.console.enable {
            console = {
                earlySetup = mkDefault true;
                colors = let
                    inherit (config.aeon.theme) colors ui;
                in [
                    # Normal
                    "000000"
                    "${colors.red}"
                    "${colors.green}"
                    "${colors.yellow}"
                    "${colors.blue}"
                    "${colors.mauve}"
                    "${colors.teal}"
                    "${ui.fg.text}"
                    # Bright
                    "${ui.fg.subtext0}"
                    "${colors.maroon}"
                    "${colors.green}"
                    "${colors.rosewater}"
                    "${colors.sapphire}"
                    "${colors.pink}"
                    "${colors.sky}"
                    "${ui.fg.text}"
                ];
            };

            fonts.packages = with pkgs; [
                aeon.iosevka-aeon
                corefonts
                font-awesome
                (nerdfonts.override { fonts = [
                    "BigBlueTerminal"
                    "JetBrainsMono"
                    "IosevkaTerm"
                ]; })
            ];
        })
    ];

}
