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
            duf       # Neat disk monitor.
            bandwhich # Bandwidth utilization tool.
            dua       # View disk space usage and delete unwanted data.

            # Networking.
            nmap         # Port scanner.
            netdiscover  # Discover hosts in LAN.
            speedtest-rs # CLI internet speedtest tool in Rust.
            ethtool      # For controlling network drivers and hardware.

            # Other TUIs.
            porsmo  # Pomodoro timer.

            # Alternative implementations of the basic tools.
            erdtree # Tree-like `ls` with a load of features.
            ripgrep # Oxidized `grep`
            killall # Basically `pkill`
            sd      # A friendlier `sed`
            srm     # Secure `rm`

            # Text & image processors.
            jq             # JSON processor.
            jaq            # Its clone in Rust.
            jc             # Parse output of various commands to JSON.
            timg           # CLI image viewer.
            toml2nix       # Convert TOML to Nix.
            exiftool       # View EXIF metadata of files.
            mpv            # Based video player.
            hexyl          # Hex viewer.
            heh            # Hex editor.
            bc             # Arbitrary precision calculator.
            aeon.repalette # Recolor images to a certain palette.

            # Build systems & automation.
            gnumake # GNU make.
            comma   # Run any binary (with `nix-index` and `nix run`)

            # Archiving tools.
            zip
            unzip
            unrar

            # Filesystems.
            e2fsprogs  # Tools for creating and checking ext2/ext3/ext4 filesystems.
            efibootmgr # Userspace EFI boot manager.

            # Fetches and other cool TUI stuff.
            neofetch
            nitch
            onefetch
            cbonsai
            cmatrix
            pipes-rs
            lolcat

            # Secrets.
            sops       # An editor of encrypted files (for `sops-nix`)
            ssh-to-age # Convert ED25519 SSH private keys to age keys.

            # Terminal recording and fun.
            vhs
            asciinema
            minesweep-rs

            # Benchmarking.
            hyperfine

            # Command managers.
            mprocs

            # My other flakes.
            inputs.reddot.packages.${pkgs.system}.default # Search for stuff in $PATH.
        ];
    };
}
