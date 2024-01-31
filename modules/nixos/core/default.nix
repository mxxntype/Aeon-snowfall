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
        inherit (config.aeon.core) enable locale timezone;
    in mkIf enable {
        # Set up root's password.
        users = {
            mutableUsers = mkDefault false;
            users.root = {
                hashedPasswordFile = config.sops.secrets."passwords/root".path;
            };
        };

        sops.secrets."passwords/root".neededForUsers = true;

        # Inherit common Nix settings.
        nix = { inherit (lib.aeon.nix) settings; };

        # Add some core packages.
        environment.systemPackages = with pkgs; [
            home-manager # Make sure its always there
            aeon.aeon
        ];

        time.timeZone = timezone;
        i18n = {
            defaultLocale = locale.main;
            supportedLocales = [ "${locale.main}/UTF-8" ] ++ (builtins.map (l: l + "/UTF-8") locale.misc);
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
