{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.core = {
        enable = mkOption {
            description = "Whether to enable core NixOS options";
            type = types.bool;
            default = true;
        };

        locale = {
            main = mkOption {
                description = "The main system locale";
                type = with types; str;
                default = "en_US.UTF-8";
            };

            misc = mkOption {
                description = "Other supported locales";
                type = with types; listOf str;
                default = [ "ru_RU.UTF-8" ];
            };
        };

        timezone = mkOption {
            type = with types; str;
            default = "Europe/Moscow";
        };

        use-uutils = mkOption {
            description = "Whether to use the Rust reimpl. of coreutils";
            type = with types; bool;
            default = false;
        };
    };

    config = let
        inherit (config.aeon.core)
            enable
            locale
            timezone
            use-uutils
            ;
    in mkIf enable {
        # Set up root's password.
        sops.secrets."passwords/root".neededForUsers = true;
        users = {
            mutableUsers = mkDefault false;
            users.root = {
                hashedPasswordFile = config.sops.secrets."passwords/root".path;
            };
        };

        # Inherit common Nix settings.
        inherit (lib.aeon) nix;

        # Allow running unpatched dynamic binaries on NixOS.
        # See https://github.com/Mic92/nix-ld.
        programs = {
            nix-ld = {
                enable = true;
                # Libraries that automatically become available to all programs.
                # The default set includes common libraries.
                libraries = [];
            };

            nh = {
                enable = true;
                clean.enable = false;
                flake = lib.aeon.flakePath;
            };
        };

        services = {
            # Populate /usr/bin/ with symlinks to executables in system's $PATH.
            # This also helps with running unpatched binaries and scripts on NixOS.
            envfs.enable = true;

            earlyoom = {
                enable = true;
                enableNotifications = true;
            };

            logind = rec {
                powerKey = "ignore";
                powerKeyLongPress = "poweroff";
                rebootKey = powerKey;
                rebootKeyLongPress = powerKeyLongPress;
                suspendKey = powerKey;
                suspendKeyLongPress = powerKeyLongPress;
                hibernateKey = powerKey;
                hibernateKeyLongPress = powerKeyLongPress;
            };

            xremap.config = {
                modmap = [
                    {
                        name = "Global modmap";
                        remap = {
                            # NOTE (at the time of introduction)
                            # I've been using LWin/LSuper as my main mod key for almost two years now
                            # with no real issues, because I was doing so on a laptop that had a left
                            # Fn key, so LWin was basically in LAlt's place, and the spacebar key was
                            # slightly shifted to the right. All of that made hitting stuff like Win+4,
                            # Win+Space, Win+Q fairly ergonomical. Now I've switched to regular 75%
                            # and TKL boards, where the LWin key is really tucked away, and my wrists
                            # are feeling dead from all of the gymnastics I have to do. I decided to
                            # remap CapsLock to Lwin, and in order to break the habit of using LWin,
                            # mapped it to F12 - couln't figure out a way to disable it completely.
                            "CapsLock" = "SUPER_L";
                            "SUPER_L" = "KEY_F12";
                        };
                    }
                ];
            };
        };

        # Add some core packages.
        environment.systemPackages = with pkgs; [
            appimage-run          # AppImage compatibility layer.
            dmidecode             # Reads information about your system's hardware from the BIOS.
            file                  # A program that shows the type of files.
            hddtemp               # Tool for displaying hard disk temperature.
            home-manager          # Make sure its always there.
            inxi                  # Full featured CLI system information tool.
            is-fast               # Check the internet as fast as possible.
            jmtpfs                # FUSE filesystem for MTP devices like Android phones.
            pciutils              # Tools for working with PCI devices, such as `lspci`.
            smartmontools         # Tools for monitoring the health of hard drives.
            usbutils              # Tools for working with USB devices, such as `lsusb`.
            wget                  # Tool for retrieving files using HTTP, HTTPS, and FTP.
            aeon.aeon             # System management script.
            aeon."iommugroups.sh" # Custom tool for inspecting IOMMU groups.
        ] ++ (if use-uutils then with pkgs; [ uutils-coreutils-noprefix ] else [ ]);

        # Set up the timezone and locale.
        time.timeZone = timezone;
        i18n = {
            defaultLocale = locale.main;
            supportedLocales = [ "${locale.main}/UTF-8" ] ++ (locale.misc |> builtins.map (l: "${l}/UTF-8"));
            extraLocaleSettings = {
                LC_CTYPE          = locale.main;
                LC_NUMERIC        = locale.main;
                LC_TIME           = locale.main;
                LC_COLLATE        = locale.main;
                LC_MONETARY       = locale.main;
                LC_MESSAGES       = locale.main;
                LC_PAPER          = locale.main;
                LC_NAME           = locale.main;
                LC_ADDRESS        = locale.main;
                LC_TELEPHONE      = locale.main;
                LC_MEASUREMENT    = locale.main;
                LC_IDENTIFICATION = locale.main;
            };
        };

        security.sudo.extraConfig = ''
            Defaults env_keep += "EDITOR"
        '';

        system = {
            rebuild.enableNg = true;
            activationScripts.linkHelixConfig = ''
                mkdir -pv /root/.config
                ln -sf /home/${lib.aeon.user}/.config/helix /root/.config/helix
            '';
        };
    };
}
