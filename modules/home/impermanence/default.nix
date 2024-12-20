{
    inputs,
    lib,
    config,
    ...
}:

with builtins;
with lib;

{
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
                xdgDirs = attrValues config.xdg.userDirs
                    |> filter (value: isString value)
                    |> map (dir: replaceStrings [ "${config.home.homeDirectory}/" ] [ "" ] dir);
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
                "Library"    # My personal library of whatnot.
                "Obsidian"   # My obsidian vault.
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
