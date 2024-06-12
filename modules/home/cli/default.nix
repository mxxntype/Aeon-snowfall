# INFO: Home-manager CLI module.

{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

with lib; {
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
            bottom.enable = true; # The cool new TUI process viewer.
            direnv = {
                enable = true;
                nix-direnv.enable = true;
            };
        };

        home.packages = with pkgs; [
            bandwhich # Bandwidth utilization tool.
            dua       # View disk space usage and delete unwanted data.
            duf       # Neat disk monitor.

            # Networking.
            ethtool      # For controlling network drivers and hardware.
            netdiscover  # Discover hosts in LAN.
            nmap         # Port scanner.
            speedtest-rs # CLI internet speedtest tool in Rust.

            # Other TUIs.
            porsmo  # Pomodoro timer.

            # Alternative implementations of the basic tools.
            erdtree # Tree-like `ls` with a load of features.
            killall # Basically `pkill`
            ripgrep # Oxidized `grep`
            sd      # A friendlier `sed`
            srm     # Secure `rm`

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
            comma   # Run any binary (with `nix-index` and `nix run`)
            gnumake # GNU make.

            # Archiving tools.
            unrar
            unzip
            zip

            # Filesystems.
            e2fsprogs  # Tools for creating and checking ext2/ext3/ext4 filesystems.
            efibootmgr # Userspace EFI boot manager.

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

            # Benchmarking.
            hyperfine

            # Command managers.
            mprocs

            # My other flakes.
            inputs.reddot.packages.${pkgs.system}.default # Search for stuff in $PATH.
        ];
    };
}
