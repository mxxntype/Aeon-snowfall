{ config, lib, ... }:

{
    options.aeon.hardware.cups = {
        enable = lib.mkOption { type = lib.types.bool; default = false; };
        server = lib.mkOption { type = lib.types.bool; default = false; };
        client = lib.mkOption { type = lib.types.bool; default = false; };
        drivers = lib.mkOption { type = lib.types.listOf lib.types.path; default = [ ]; };
    };

    config = let
        inherit (config.aeon.hardware.cups)
            enable
            server
            client
            drivers;
    in (lib.mkIf enable (lib.mkMerge [
        {
            services = {
                printing.enable = true;
                avahi = {
                    enable = true;
                    nssmdns4 = true;
                };
            };
        }  

        (lib.mkIf client {
            services.printing.browsed.enable = true;
        })

        (lib.mkIf server {
            services = {
                printing = {
                    inherit drivers;

                    listenAddresses = [ "*:631" ];
                    allowFrom = [ "all" ];
                    browsing = true;
                    defaultShared = true;
                    openFirewall = true;

                    browsed.enable = false;
                };

                avahi = {
                    openFirewall = true;
                    publish = {
                        enable = true;
                        userServices = true;
                    };
                };
            };
        })
    ]));
}
