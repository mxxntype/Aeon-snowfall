{ config, pkgs, lib, ... }:

{
    options.aeon.apps.obsidian = {
        enable = lib.mkEnableOption "the Obsidian MD suite";
    };

    config = let cfg = config.aeon.apps.obsidian; in lib.mkIf cfg.enable {
        home.packages = with pkgs; [ obsidian ];
    };
}
