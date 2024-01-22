# INFO: NixOS Boot module.

{
    config,
    lib,
    ...
}:

with lib; {
    options.aeon.boot = {
        type = mkOption {
            type = types.enum [ "bios" "uefi" "lanzaboote" ];
            default = "uefi";
            description = "What type of bootloader module to use";
        };

        quiet = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable Plymouth and reduce TTY verbosity";
        };

        grub.device = mkOption {
            type = types.str;
            default = "nodev";
            description = "Link to boot.loader.grub.device";
        };
    };

    config = let
        inherit (config.aeon.boot) type quiet;
        inherit (config.aeon.boot.grub) device;
    in mkMerge [
        # Use GRUB2 by default.
        {
            boot.loader.grub = {
                enable = mkDefault true;
                inherit device;
            };
        }

        # BIOS:
        (mkIf (type == "bios") {
            boot = {
                loader = {
                    grub = {
                        efiSupport = mkDefault false;
                    };
                };
            };
        })

        # UEFI: common options.
        (mkIf (type == "uefi" || type == "lanzaboote") {
            boot = {
                loader = {
                    efi = {
                        efiSysMountPoint = mkDefault "/boot/efi";
                        canTouchEfiVariables = true;
                    };
                };
            };
        })

        # UEFI: GRUB2 non-secure boot.
        (mkIf (type == "uefi") {
            boot = {
                loader = {
                    grub = {
                        efiSupport = true;
                        efiInstallAsRemovable = mkDefault false;
                    };
                };
            };
        })

        # UEFI: Secure boot.
        #
        # INFO: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
        (mkIf (type == "lanzaboote") {
            environment.systemPackages = with pkgs; [ sbctl ];
            boot = {
                lanzaboote = {
                    enable = true;
                    pkiBundle = "/etc/secureboot";
                };
                loader = {
                    # HACK: Lanzaboote currently replaces systemd-boot, so force it to false for now.
                    systemd-boot.enable = mkForce false;
                    grub.enable = mkForce false;
                };
            };
        })
        
        # Quiet boot with minimal logging.
        (mkIf quiet {
            boot = {
                plymouth = {
                    enable = true;
                    theme = "breeze";

                    # TODO: Configure font & logo.
                    # font = "${pkgs.nerdfonts.override { fonts = [ ]; }}/share/fonts/...";
                    # logo = .../logo.png;
                };

                consoleLogLevel = 0;
                kernelParams = [
                    "quiet"
                    "loglevel=3"
                    "systemd.show_status=auto"
                    "udev.log_level=3"
                    "rd.udev.log_level=3"
                    "vt.global_cursor_default=0"
                ];

                initrd = {
                    systemd.enable = true;
                    verbose = false;
                };
            };
        })
    ];
}
