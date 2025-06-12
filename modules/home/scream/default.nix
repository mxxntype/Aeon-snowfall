{ config, pkgs, lib, ... }: with lib;

{
    options.aeon.scream = with types; {
        enable = mkOption { type = bool; default = false; };
    };

    config = mkIf config.aeon.scream.enable {
        home.packages = with pkgs; [ scream ];

        systemd.user.services.scream-listener = {
            Unit = {
                Description = "Scream network audio listener";
                After = [ "default.target" ];
            };

            Service = {
                ExecStart = "${pkgs.scream}/bin/scream -o pulse";
                Restart = "always";
            };

            Install.WantedBy = [ "default.target" ];
        };
    };
}
