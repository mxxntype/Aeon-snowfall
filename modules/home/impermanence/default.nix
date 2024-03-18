{
    inputs,
    lib,
    config,
    ...
}:

with lib; {
    imports = with inputs; [
        impermanence.nixosModules.home-manager.impermanence
    ];

    options.aeon.impermanence = {
        enable = mkOption {
            type = with types; bool;
            default = true;
            description = "Whether to apply common configurations to Impermanence";
        };
    };

    config = let
        inherit (config.aeon.impermanence)
            enable
            ;
    in mkIf enable {
        home.persistence."${lib.aeon.persist}/home/${lib.aeon.user}" = {
            directories = let
                xdgDirs = builtins.map
                    (dir: builtins.replaceStrings [ "${config.home.homeDirectory}/" ] [ "" ] dir)
                    (builtins.filter
                        (value: builtins.isString value)
                        (builtins.attrValues config.xdg.userDirs));
            in xdgDirs ++ [
                ".gnupg"
                ".ssh"
                ".local/share/keyrings"
                ".local/share/direnv"
            ];
            files = [ ".wallpaper" ];
            allowOther = true;
        };
    };
}
