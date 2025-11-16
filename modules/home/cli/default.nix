# INFO: Home-manager CLI module.

{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.cli = {
        enable = mkOption {
            description = "Whether to enable core CLI functionality";
            type = with types; bool;
            default = true;
        };
    };

    config = mkIf config.aeon.cli.enable {
        programs = {
            htop.enable = true;   # The well-known TUI process viewer.
            
            # The cool new TUI process viewer.
            bottom = {
                enable = true;
                settings.styles.widgets = {
                    border_color = "dark gray";
                    selected_border_color = "white";
                };
            };

            direnv = {
                enable = true;
                nix-direnv.enable = true;
                # HACK: The home-manager module (https://github.com/nix-community/home-manager/blob/29ab63bbb3d9eee4a491f7ce701b189becd34068/modules/programs/direnv.nix)
                # generates some nushell code that uses a deprecated flag. The PR with the fix
                # (https://github.com/nix-community/home-manager/pull/7490) is already in the
                # master branch, however, I have not yet updated to 25.11.
                enableNushellIntegration = false;
            };

            yazi = {
                enable = true;
                plugins = {
                    inherit (pkgs.yaziPlugins) git;
                };
            };
        };

        home.packages = with pkgs; [
            # System information stuff.
            dua   # View disk space usage and delete unwanted data.
            duf   # Neat disk monitor.
            kondo # Disposal of build artifacts.
            tokei # Cool LOC counter.

            # Alternative implementations of the basic tools.
            erdtree # Tree-like `ls` with a load of features.
            killall # Basically `pkill`.
            ripgrep # Oxidized `grep`.
            sd      # A friendlier `sed`.
            srm     # Secure `rm`.

            # Text & image processors.
            aeon.repalette # Recolor images to a certain palette.
            bc             # Arbitrary precision calculator.
            exiftool       # View EXIF metadata of files.
            heh            # Hex editor.
            hexyl          # Hex viewer.
            jaq            # `jq` clone in Rust.
            jc             # Parse output of various commands to JSON.
            jq             # JSON processor.
            mpv            # Based video player.
            timg           # CLI image viewer.
            toml2nix       # Convert TOML to Nix.

            # Color processors.
            matugen # Material You color generation tool.
            pastel  # Generate, analyze, convert and manipulate colors.

            # Build systems & automation.
            cmake   # Cross-platform, open-source build system generator (dumpster fire).
            comma   # Run any binary (with `nix-index` and `nix run`)
            gnumake # GNU make.
            meson   # Open source, fast and friendly build system made in Python.
            ninja   # Small build system with a focus on speed.

            # Archiving tools.
            unrar
            unzip
            zip

            # Fetches and other cool TUI stuff.
            cbonsai
            cmatrix
            lolcat
            neofetch
            nitch
            onefetch
            pipes-rs

            # Terminal recording and fun.
            asciinema
            minesweep-rs
            vhs

            hyperfine # Quick CLI benchmarking tool.
            mprocs    # TUI command manager.
            porsmo    # Pomodoro timer.
            pv        # Tool for monitoring the progress of data through a pipeline.
        ];
    };
}
