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

    config = mkMerge [
        # Use GRUB2 by default.
        {
            boot.loader.grub = {
                enable = mkDefault true;
                inherit (config.aeon.boot.grub) device;
            };
        }

        # Legacy BIOS boot.
        (mkIf (config.aeon.boot.type == "bios") {
            boot = {
                loader = {
                    grub = {
                        efiSupport = mkDefault false;
                    };
                };
            };
        })

        # UEFI boot.
        (mkIf (config.aeon.boot.type == "uefi") {
            boot = {
                loader = {
                    grub = {
                        efiSupport = true;
                        efiInstallAsRemovable = mkDefault false;
                    };

                    efi = {
                        efiSysMountPoint = mkDefault "/boot/efi";
                        canTouchEfiVariables = true;
                    };
                };
            };
        })

        # UEFI Secure boot.
        #
        # INFO: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
        (mkIf (config.aeon.boot.type == "lanzaboote") {
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
        
        # Quiet boot.
        (mkIf config.aeon.boot.quiet {
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
