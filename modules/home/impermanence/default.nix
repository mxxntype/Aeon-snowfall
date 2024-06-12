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
            default = false;
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
                ".android"   # ADB data.
                ".cache"     # All kinds of cached stuff.
                ".cargo"     # Cargo package (meta)data.
                ".docker"    # Docker data.
                ".gnupg"     # GPG data.
                ".icons"     # Well, icons.
                ".java"      # Stuff pulled in by JDK's and Java apps.
                ".librewolf" # Librewolf's data.
                ".local"     # All kinds of data.
                ".mozilla"   # Firefox's data.
                ".rustup"    # Rust toolchain cache.
                ".ssh"       # SSH keys and authorized hosts.
                ".var"       # Mostly Flatpak stuff.
                "Aeon"       # Where this repo lives.
                "Camera"     # My phone's gallery (synced)
                "Files"      # Assorted files (.iso images, keys, AppImages, other stuff)
                "Library"    # My personal library of whatnot (TODO: Merge with ~/Documents)
                "Obsidian"   # My obsidian vault (TODO: Move to ~/Documents)
                "Projects"   # My personal and work projects.
                "Repos"      # Cloned repositories.
                "exercism"   # https://exercism.org stuff.
                "pt"         # Cisco Packet Tracer stuff.
            ];
            files = [ ".wallpaper" ];
            allowOther = true;
        };
    };
}
