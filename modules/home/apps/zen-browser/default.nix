{
    config,
    pkgs,
    lib,
    ...
}:

with lib; {
    options.aeon.apps.zen-browser = {
        enable = mkOption {
            type = with types; bool;
            default = true;
        };

        makeDefault = mkOption {
            type = with types; bool;
            default = true;
        };
    };

    config = let
        desktopEntry = "zen-browser";
        inherit (config.aeon.apps.zen-browser)
            enable
            makeDefault
            ;
    in mkIf enable {
        home.packages = with pkgs; [ aeon.zen-browser ];
        xdg = {
            enable = true;
            desktopEntries."${desktopEntry}" = {
                name = "Zen Browser";
                genericName = "Web Browser";
                exec = "${pkgs.aeon.zen-browser}";
                terminal = false;
                mimeType = [
                    "text/html"
                    "text/xml"
                ];
            };

            mime.enable = makeDefault;
            mimeApps = let
                zenDesktop = "${desktopEntry}.desktop";
                mimes = {
                    "text/html" = zenDesktop;
                    "x-scheme-handler/http" = zenDesktop;
                    "x-scheme-handler/https" = zenDesktop;
                    "x-scheme-handler/about" = zenDesktop;
                    "x-scheme-handler/unknown" = zenDesktop;
                };
            in mkIf makeDefault {
                enable = true;
                associations.added = mimes;
                defaultApplications = mimes;
            };
        };
    };
}
