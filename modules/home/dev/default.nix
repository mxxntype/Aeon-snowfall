{ config, lib, pkgs, ... }:

{
    options.aeon.dev.core = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
    };

    config = lib.mkIf config.aeon.dev.core.enable {
        home.packages = with pkgs; [
            gegl.dev    # Graph-based image processing framework.
            graphviz    # Graph visualization tools.
            imagemagick # Software suite to create, edit, compose, or convert bitmap images
            typos       # Source code spell checker.

            # FIXME: Can't locate `libssl.so.3` (FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK)
            # aeon.invar # My CLI management tool for modded Minecraft servers.
        ];
    };
}
