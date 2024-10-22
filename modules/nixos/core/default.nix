# INFO: Core NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
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
    };

    config = let
        inherit (config.aeon.core)
            enable
            locale
            timezone
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
        nix = { inherit (lib.aeon.nix) settings; };

        # Allow running unpatched dynamic binaries on NixOS.
        # See https://github.com/Mic92/nix-ld.
        programs.nix-ld = {
            enable = true;
            # Libraries that automatically become available to all programs.
            # The default set includes common libraries.
            libraries = [];
        };

        # Add some core packages.
        environment.systemPackages = with pkgs; [
            home-manager          # Make sure its always there.
            file                  # A program that shows the type of files.
            jmtpfs                # FUSE filesystem for MTP devices like Android phones.
            pciutils              # Tools for working with PCI devices, such as `lspci`.
            usbutils              # Tools for working with USB devices, such as `lsusb`.
            wget                  # Tool for retrieving files using HTTP, HTTPS, and FTP.
            aeon.aeon             # System management script.
            aeon."iommugroups.sh" # Custom tool for inspecting IOMMU groups.
        ];

        # Set up the timezone and locale.
        time.timeZone = timezone;
        i18n = {
            defaultLocale = locale.main;
            supportedLocales = [ "${locale.main}/UTF-8" ] ++ (builtins.map (l: "${l}/UTF-8") locale.misc);
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
    };
}
