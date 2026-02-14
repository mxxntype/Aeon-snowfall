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
            aeon.cpx # Modern replacement for the traditional `cp`.
            erdtree  # Tree-like `ls` with a load of features.
            killall  # Basically `pkill`.
            ripgrep  # Oxidized `grep`.
            sd       # A friendlier `sed`.
            srm      # Secure `rm`.

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
            pwgen     # CLI password generator.
        ];

        xdg.configFile."cpx/cpxconfig.toml".text = /* toml */ ''
            [exclude]
            patterns = []
            [copy]
            parallel = 4
            recursive = false
            parents = false
            force = false
            interactive = false
            resume = false
            attributes_only = false
            remove_destination = false
            [preserve]
            mode = "default"
            [symlink]
            mode = ""
            follow = ""
            [backup]
            mode = "none"
            [reflink]
            mode = ""
            [progress]
            style = "detailed"
            [progress.bar]
            filled = "█"
            empty = "░"
            head = "░"
            [progress.color]
            bar = "green"
            message = "white"
        '';
    };
}
