# INFO: Whoogle module for NixOS.
#
# Whoogle is a self-hosted, ad-free, privacy-respecting metasearch engine.
# 
# Get Google search results, but without any ads, JavaScript, AMP links,
# cookies, or IP address tracking. Easily deployable in one click as a Docker
# app, and customizable with a single config file. Quick and simple to
# implement as a primary search engine replacement on both desktop and mobile.

{
    lib,
    config,
    ...
}:

with lib; {
    options.aeon.services.whoogle = {
        enable = mkOption {
            type = with types; bool;
            default = false;
            description = "Whether to enable the Whoogle search engine";
        };
    };

    config = let
        port = 8080;
        inherit (config.aeon.services.whoogle)
            enable
            ;
        inherit (config.aeon.theme)
            colors
            ui
            code
            ;
    in mkIf enable {
        virtualisation.oci-containers.containers = {
            "whoogle" = {
                image = "benbusby/whoogle-search";
                ports = [ "${toString port}:5000" ];
                user = "whoogle";
                environment = {
                    WHOOGLE_TOR_SERVICE  = "0";
                    WHOOGLE_UPDATE_CHECK = "0";
                    WHOOGLE_CONFIG_STYLE =
                        builtins.replaceStrings
                            [ "\n" ]
                            [ " " ]
                            /* css */ ''
                                :root {
                                    --whoogle-dark-logo:           #${ui.fg.text};
                                    --whoogle-dark-page-bg:        #${ui.bg.base};
                                    --whoogle-dark-element-bg:     #${ui.bg.surface1};
                                    --whoogle-dark-text:           #${ui.fg.text};
                                    --whoogle-dark-contrast-text:  #${ui.fg.subtext1};
                                    --whoogle-dark-secondary-text: #${ui.fg.subtext1};
                                    --whoogle-dark-result-bg:      #${ui.bg.surface0};
                                    --whoogle-dark-result-title:   #${ui.accent};
                                    --whoogle-dark-result-url:     #${code.url};
                                    --whoogle-dark-result-visited: #${code.url};
                                }
                        
                                #whoogle-w   { fill: #${colors.blue};   }
                                #whoogle-h   { fill: #${colors.red};    }
                                #whoogle-o-1 { fill: #${colors.mauve};  }
                                #whoogle-o-2 { fill: #${colors.cyan};   }
                                #whoogle-g   { fill: #${colors.green};  }
                                #whoogle-l   { fill: #${colors.pink};   }
                                #whoogle-e   { fill: #${colors.yellow}; }
                            '';
                };
            };
        };
    };
}
