{
    lib,
    config,
    ...
}:

with lib; {
    options = {
        aeon.core.enable = mkOption {
            description = "Whether to enable core Home-manager options";
            type = types.bool;
            default = true;
        };
    };
    
    config = mkIf config.aeon.core.enable {
        nix = {
            settings = {
                experimental-features = [ "nix-command" "flakes" "repl-flake" ];
                warn-dirty = false;
            };
        };

        programs = {
            home-manager.enable = mkForce true; # Home-manager absolutely should stay enabled.
            nix-index.enable = true;            # A files database for Nixpkgs.
        };

        home = {
            homeDirectory = mkForce "/home/${config.home.username}";
            sessionVariables = {
                XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
            };
        };

        xdg = {
            enable = true;
            userDirs = let
                inherit (config.home) homeDirectory;
            in {
                enable = true;
                createDirectories = true;
                desktop = "${homeDirectory}/Desktop";
                documents = "${homeDirectory}/Documents";
                music = "${homeDirectory}/Music";
                pictures = "${homeDirectory}/Images";
            };

            mime.enable = true;
            mimeApps = let
                mimes = {};
            in {
                enable = true;
                associations.added = mimes;
                defaultApplications = mimes;
            };
        };

        # Nicely reload user services on rebuild.
        systemd.user.startServices = "sd-switch";
    };
}
