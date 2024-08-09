{
    config,
    lib,
    pkgs,
    ...
}: 

with lib; {
    options.aeon.cli.just.enable = mkOption {
        description = "Whether to enable just - a handy way to save and run project-specific commands";
        type = with types; bool;
        default = true;
    };

    config = let
        inherit (config.aeon.cli.just)
            enable
            ;
    in mkIf enable {
        home = {
            packages = with pkgs; [ just ];
        };
    };
}
