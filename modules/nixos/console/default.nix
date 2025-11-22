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

                # HACK: https://github.com/apognu/tuigreet/issues/17#issuecomment-949757598
                # Forces greetd to use the second VT, while systemd logs to VT 1. This dirty
                # hack resolves the issue of greetd being covered by systemd logs.
                vt = 2;
            };

            boot.kernelParams = [ "console=tty1" ];
            systemd.services.greetd.serviceConfig.Type = lib.mkForce "simple";

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

            fonts.packages = let
                GUIfonts = (with pkgs; [
                    aeon.iosevka-aeon
                    aeon.nunito
                    corefonts
                    font-awesome
                    google-fonts
                ]) ++ (with pkgs.nerd-fonts; [
                    bigblue-terminal
                    iosevka-term
                    jetbrains-mono
                    lilex
                    zed-mono
                ]);
            in if config.aeon.hardware.meta.headless
                then [ ]
                else GUIfonts; 
        })
    ];

}
