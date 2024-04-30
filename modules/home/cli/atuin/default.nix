# INFO: Atuin Home-manager module.
#
# FIXME: Tweak & incude the `init.nu` file.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.atuin = {
        enable = mkOption {
            description = "Whether to enable Atuin, the magical shell history";
            type = types.bool;
            default = false; # TODO
        };

        sync = mkOption {
            description = "Whether to use Atuin's sync feature";
            type = types.bool;
            default = false;
        };

        host = mkOption {
            description = "Whether to host an Atuin server";
            type = types.bool;
            default = false;
        };
    };

    config = mkMerge [
        # Configure an Atuin client.
        (mkIf config.aeon.cli.atuin.enable {
            programs.atuin = {
                enable = true;
                flags = [ "--disable-up-arrow" ];
                settings = {
                    auto_sync = false;
                    update_check = false;
                    search_mode = "fuzzy";
                    filter_mode = "host";
                    secrets_filter = true;
                    style = "compact";
                    inline_height = 24;
                };
            };

            home.packages = with pkgs; [ atuin ];
        })    

        # TODO: Configure Atuin's sync feature.
        (mkIf config.aeon.cli.atuin.sync {
            programs.atuin.settings = {
                auto_sync = true;
                sync_frequency = "10m";
                sync_address = "https://api.atuin.sh"; # FIXME
                filter_mode = "global";
                search_mode = "prefix";
            };
        })

        # TODO: Configure an Atuin server.
        (mkIf config.aeon.cli.atuin.host { })    
    ];
}
