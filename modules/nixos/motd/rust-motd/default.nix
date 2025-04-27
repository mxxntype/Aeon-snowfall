# INFO: rust-motd, a Message Of The Day (MOTD) generator.

{ config, lib, ... }: with lib;

{
    options.aeon.motd.rust-motd = {
        enable = mkOption {
            description = "Whether to enable rust-motd";
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.motd.rust-motd)
            enable
            ;
    in mkMerge [
        (mkIf enable {
            programs.rust-motd = {
                enable = true;
                settings = {
                    last_login = { mxxntype = 3; };
                    memory.swap_pos = "beside";
                    uptime.prefix = "Up";

                    global = {
                        progress_empty_character = "-";
                        progress_full_character = "=";
                        progress_prefix = "[";
                        progress_suffix = "]";
                        time_format = "%Y-%m-%d %H:%M:%S";
                    };

                    banner = {
                        command = "echo GET IN THE FUKKEN ROBOT SHINJI";
                        color = "magenta";
                    };

                    filesystems = {
                        root = "/";
                        boot = "/boot";
                    };
                };
            };
        })
    ];

}
