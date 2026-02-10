{ config, pkgs, lib, ... }:

{
    options.aeon.apps.office = {
        enable = lib.mkEnableOption "office apps";
    };

    config = let cfg = config.aeon.apps.office;
    in lib.mkIf cfg.enable {
        home.packages = with pkgs; [ libreoffice-fresh ];
        programs.onlyoffice.enable = true;
    };
}
