# INFO: Linux console/TTY NixOS module.

{ config, pkgs, lib, ... }: with lib;

{
    options.aeon.console = {
        enable = mkOption {
            description = "Whether to configure the Linux TTY";
            type = types.bool;
            default = true;
        };
    };

    config = mkMerge [
        (mkIf config.aeon.console.enable {
            services.greetd = {
                enable = true;
                settings = {
                    default_session = {
                        user = "greeter";
                        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd hyprland";
                        #                                                                       ^^^^^^^^
                        # FIXME: This command is hardcoded for now, but I really should implement a module
                        # that would actually reflect what the default "environment entrypoint" is.
                    };
                };
            };

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
                aeon.nunito
                corefonts
                font-awesome
            ] ++ (with pkgs.nerd-fonts; [
                bigblue-terminal
                iosevka-term
                jetbrains-mono
            ]);
        })
    ];

}
