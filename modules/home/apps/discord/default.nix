# INFO: Discord Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.apps.discord = {
        enable = mkOption {
            type = with types; bool;
            default = false;
            description = "Whether to enable Discord";
        };

        app = mkOption {
            type = with types; enum [ "vencord" ];
            default = "vencord";
            description = "What Discord client to use";
        };
    };

    config = let
        inherit (config.aeon.apps.discord)
            enable
            app
            ;
    in mkIf enable (mkMerge [
        (mkIf (app == "vencord") {
            home = {
                packages = with pkgs; [ vesktop ];
                persistence."${lib.aeon.persist}/home/${lib.aeon.user}" = {
                    directories = [
                        ".config/vesktop"
                        ".config/VencordDesktop"
                    ];
                };
            };
        })
    ]);
}
