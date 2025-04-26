# INFO: NixOS module with Zapret, the based-as-fuck DPI bypass tool.

{
    config,
    lib,
    ...
}:

with lib;

{
    options.aeon.net.zapret = {
        enable = mkOption {
            type = types.bool;
            default = false;
        };

        params = mkOption {
            type = with types; listOf str;
            default = [
                "--dpi-desync=fake,disorder"
                "--dpi-desync-ttl=3"
            ];
        };

        whitelist = mkOption {
            type = with types; listOf str;
            default = [
                "discord.com"
                "element.io"
                "googlevideo.com"
                "matrix.org"
                "youtu.be"
                "youtube.com"
                "ytimg.com"
            ];
        };
    };

    config = let
        inherit (config.aeon.net.zapret)
            enable
            params
            whitelist
            ;
    in mkIf enable {
        services.zapret = {
            inherit
                enable
                params
                whitelist
                ;
        };
    };
}
