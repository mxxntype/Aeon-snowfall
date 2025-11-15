{ config, lib, pkgs, inputs, ... }:

{
    options.aeon.dev.core = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
    };

    config = lib.mkIf config.aeon.dev.core.enable {
        home.packages = with pkgs; [
            ffmpeg      # Complete, cross-platform solution to record, convert and stream audio and video.
            gegl.dev    # Graph-based image processing framework.
            graphviz    # Graph visualization tools.
            imagemagick # Software suite to create, edit, compose, or convert bitmap images
            typos       # Source code spell checker.

            # My CLI management tool for modded Minecraft servers.
            inputs.invar.packages.${system}.default
        ];
    };
}
