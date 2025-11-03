{ config, lib, ... }:

{
    options.aeon.stylesheets.enable =
        lib.mkOption { type = lib.types.bool; default = false; };
    
    config = let dir = "stylesheets";
    in lib.mkIf config.aeon.stylesheets.enable {
        xdg.configFile = {
            "${dir}/ddg.less".text =
                lib.aeon.generators.stylesheets.ddg { inherit (config.aeon) theme; };

            "${dir}/github.less".text =
                lib.aeon.generators.stylesheets.github { inherit (config.aeon) theme; };

            "${dir}/nixos-search.less".text =
                lib.aeon.generators.stylesheets.nixos-search { inherit (config.aeon) theme; };

            "${dir}/nixos-wiki.less".text =
                lib.aeon.generators.stylesheets.nixos-wiki { inherit (config.aeon) theme; };

            "${dir}/stylus.less".text =
                lib.aeon.generators.stylesheets.stylus { inherit (config.aeon) theme; };

            "${dir}/docs.rs.less".text =
                lib.aeon.generators.stylesheets.docs-rs {
                    theme = config.aeon.theme;
                    inherit (config.home) homeDirectory;
                };
        };
    };
}
