# INFO: General Dev Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.core = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.dev.core)
            enable
            ;
    in mkIf enable {
        home.packages = with pkgs; [
            typos      # Source code spell checker.
            graphviz   # Graph visualization tools.

            # FIXME: Can't locate `libssl.so.3` (FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK)
            # aeon.invar # My CLI management tool for modded Minecraft servers.
        ];
    };
}
