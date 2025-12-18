{ config, lib, pkgs, ... }: 

{
    options.aeon.apps.librewolf = {
        enable = lib.mkEnableOption "enable Librewolf";
    };

    config = let cfg = config.aeon.apps.librewolf; in (lib.mkIf cfg.enable {
        programs.librewolf = {
            enable = true;
            languagePacks = [ "en-US" ];

            policies = {
                # Updates & Background Services
                AppAutoUpdate = false;
                BackgroundAppUpdate = false;

                # Feature Disabling
                DisableBuiltinPDFViewer = false;
                DisableFirefoxStudies = true;
                DisableFirefoxAccounts = true;
                DisableFirefoxScreenshots = true;
                DisableForgetButton = true;
                DisableMasterPasswordCreation = true;
                DisableProfileImport = true;
                DisableProfileRefresh = true;
                DisableSetDesktopBackground = true;
                DisablePocket = true;
                DisableTelemetry = true;
                DisableFormHistory = true;
                DisablePasswordReveal = true;

                # Access Restrictions
                BlockAboutConfig = false;
                BlockAboutProfiles = true;
                BlockAboutSupport = true;

                # UI and Behavior
                DisplayMenuBar = "never";
                DisplayBookmarksToolbar = "never";
                DontCheckDefaultBrowser = true;
                HardwareAcceleration = true;
                OfferToSaveLogins = false;
                DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
            };

            profiles.default = {
                settings = {
                    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
                };

                extensions = {
                    force = true;

                    packages = with pkgs; [
                        nur.repos.rycee.firefox-addons.ublock-origin
                        # nur.repos.rycee.firefox-addons.decentraleyes
                    ];

                    settings = {
                        "uBlock0@raymondhill.net".settings = let
                            inherit (config.aeon) theme;
                        in {
                            uiTheme = "dark";
                            uiAccentCustom = true;
                            uiAccentCustom0 = "#${theme.ui.accent}";
                            cloudStorageEnabled = lib.mkForce false;

                            selectedFilterLists = [
                                "ublock-filters"
                                "ublock-badware"
                                "ublock-privacy"
                                "ublock-unbreak"
                                "ublock-quick-fixes"
                            ];
                        };
                    };
                };

                search = {
                    force = true;
                    default = "ddg";
                    privateDefault = "ddg";

                    engines = {
                        "MyNixOS" = {
                            definedAliases = [ "!mn" ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                            urls = [
                                {
                                    template = "https://mynixos.com/search";
                                    params = [ { name = "q"; value = "{searchTerms}"; } ];
                                }
                            ];
                        };

                        "NixOS Wiki" = {
                            definedAliases = [ "!nw" ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                            urls = [
                                {
                                    template = "https://wiki.nixos.org/w/index.php";
                                    params = [
                                        { name = "search"; value = "{searchTerms}"; }
                                    ];
                                }
                            ];
                        };

                        "Nix Packages" = {
                            definedAliases = [ "!np" ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                            urls = [
                                {
                                    template = "https://search.nixos.org/packages";
                                    params = [
                                        { name = "channel"; value = "unstable"; }
                                        { name = "query";   value = "{searchTerms}"; }
                                    ];
                                }
                            ];
                        };

                        "Nix Options" = {
                            definedAliases = [ "!no" ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                            urls = [
                                {
                                    template = "https://search.nixos.org/options";
                                    params = [
                                        { name = "channel"; value = "25.11"; }
                                        { name = "query";   value = "{searchTerms}"; }
                                    ];
                                }
                            ];
                        };
                    };
                };
            };
        };
    });
}
