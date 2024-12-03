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
            default = true;
        };

        params = mkOption {
            type = with types; listOf str;
            default = [
                "--dpi-desync=fake,disorder"
                "--dpi-desync-ttl=3"
            ];
        };
    };

    config = let
        inherit (config.aeon.net.zapret)
            enable
            params
            ;
    in mkIf enable {
        services.zapret = {
            inherit enable params;
            whitelist = [
                "youtube.com"
                "googlevideo.com"
                "ytimg.com"
                "youtu.be"
            ];
        };
    };
}
