# INFO: Docker module for NixOS.

{
    pkgs,
    lib,
    config,
    ...
}:

with lib; {
    options.aeon = {
        docker = {
            enable = mkOption {
                type = with types; bool;
                default = false;
                description = "Whether to enable the Docker daemon";
            };
        };
    };

    config = let
        inherit (config.aeon.docker)
            enable
            ;
    in mkIf enable {
        virtualisation.docker.enable = true;
        environment.systemPackages = with pkgs; [ docker-compose ];
    };
}
