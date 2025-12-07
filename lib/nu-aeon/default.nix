{ lib, ... }:

{
    # INFO: Initially, the `aeon` script was provided as an external nu script.
    # However, that came with a downside of not being "native" to the actual
    # interactive shell, thus:
    # 1) No shell completions could be provided;
    # 2) The script's output would be interpreted as a byte stream.
    #    This is the main pain in the ass: even if the script itself
    #    returned a Nu data structure, the invoking shell would read
    #    is as raw bogus shit, rendering it at best very ankward and
    #    at worst impossible to interact with that output in the Nu
    #    way. And also, colors got messed up.
    # 
    # What you see below is, I guess, the implementation of `aeon` the way it
    # should have been from the start - as a function that returns a Nu script
    # as raw text, and that can be embedded into a file, or into Nushell's
    # config file, fixing both of the pain point above.
    nu-aeon.script = {
        # NOTE: Since we're in a library part, we do not have access to a `pkgs`
        # thing like we would in a NixOS module. This is perhaps even better:
        # this way, the raw text of the script will always contain correct nix
        # paths when called from a nix module.
        pkgs ? throw "A nixpkgs instance was not provided",

        functionName,
    }:

    /* nu */ ''
        # A Nushell script for managing and installing Aeon systems.
        def ${functionName} []: nothing -> nothing {
            print (sys host)
            print $"(ansi green)note: (ansi reset)Run (ansi {fg: cyan, bg: dark_gray}) aeon --help (ansi reset) to see more options."
        }

        # Garbage-collect the system.
        def "${functionName} gc" []: nothing -> nothing {
            home-manager expire-generations 0
            sudo nix-collect-garbage -d
            nix store optimise
        }

        # Perform a system rebuild.
        def "${functionName} rebuild" [
            --flake (-f): directory = /home/${lib.aeon.user}/Aeon # Path to flake.
            --rebuild-system (-S) # Rebuilt the NixOS configuration.
            --rebuild-home (-H) # Rebuild the Home-manager configuration.
        ]: nothing -> nothing {
            if (not $rebuild_home) and (not $rebuild_system) {
                print $"(ansi red)note: (ansi reset)No action specified. Run with --help for options."
            }
            if $rebuild_home { ${lib.getExe pkgs.nh} home switch $flake --ask --backup-extension backup }
            if $rebuild_system { ${lib.getExe pkgs.nh} os switch $flake --ask }
        }

        # Check the status of the VPN (and Tailscale).
        def "${functionName} vpn status" []: nothing -> record {
            let tailscale = try { tailscale status } catch { "inactive" };
            let personal = try { systemctl is-active wg-quick-personal.service } catch { "inactive" }
            let invian = try { systemctl is-active wg-quick-invian.service } catch { "inactive" }
            {
                tailscale: ($tailscale != "inactive"),
                vpn: {
                    personal: ($personal == "active"),
                    invian: ($invian == "active"),
                }
            }
        }

        # Active a VPN service, if configured.
        def "${functionName} vpn connect" [
            interface: string # The name of the interface to connect to.
        ]: nothing -> nothing {
            let status = aeon vpn status;
            try {
                if ($status.vpn | get $interface) == false {
                    sudo systemctl start $"wg-quick-($interface)"
                    print $"(ansi green)STATUS:(ansi reset) Connected to VPN, Tailscale is (ansi red)down(ansi reset) for now."
                } else {
                    print $"(ansi green)STATUS:(ansi reset) Already connected. Tailscale is (ansi red)down(ansi reset)."
                }
            } catch {
                print $"(ansi red)ERROR:(ansi reset) Can't interact with the VPN service. Is this one configured?"
            }
        }

        # Deactivate a VPN service, if configured.
        def "${functionName} vpn disconnect" [
            interface: string # The name of the interface to disconnect from.
        ]: nothing -> nothing {
            let status = aeon vpn status;
            try {
                if ($status.vpn | get $interface) == true {
                    sudo systemctl stop $"wg-quick-($interface)"
                    print $"(ansi green)STATUS:(ansi reset) Stopping the VPN, Tailscale is now (ansi green)up(ansi reset)."
                } else {
                    print $"(ansi green)STATUS:(ansi reset) Not yet connected. Tailscale is (ansi green)up(ansi reset)."
                }
            } catch {
                print $"(ansi red)ERROR:(ansi reset) Can't interact with the VPN service. Is this one configured?"
            }
        }

        # Run a QEMU VM with a NixOS system.
        def "${functionName} vm" [
            system: string = "illusion" # Which system to virtualize.
            --flake (-f): directory = "${lib.aeon.flakePath}" # Path to flake.
            --fresh (-F) # Delete ./<system>.qcow2 if found.
        ]: nothing -> nothing {
            if $fresh { do -i { rm $"($system)" } }
            nixos-rebuild build-vm --flake $"($flake)\#($system)"
            ${pkgs.bash}/bin/bash $"./result/bin/run-($system)-vm"
        }

        # Wait until there are no active login sessions.
        def "${functionName} wait-idle" [
            --interval (-i): duration = 30sec # How long to wait for between checks.
        ]: nothing -> nothing {
            loop {
                let session_count = loginctl list-sessions --json=short
                    | from json
                    | where class != manager
                    | where user == root or user == ${lib.aeon.user}
                    | length
                if $session_count  == 0 { break }

                print "Unterminated sessions detected, waiting"
                sleep $interval
            }
        }

        # Perform a semi-automatic NixOS install using Disko.
        def "${functionName} install" [
            hostname: string # Future hostname of the installed system.
            platform: string = "x86_64-linux" # Target platform (architecture).
            --mode: string = "mount" # The mode in which Disko runs.
            --mount (-m): directory = /mnt # Where to mount the target drive.
            --install (-I) # Run nixos-install.
            --ignore-generated-config (-i) # Do not automatically inherit `boot.*` options from `nixos-generate-config`.
            --copy-to: directory = /home/${lib.aeon.user} # Where to copy the repo (in /mnt).
            --no-copy-repo # Do not copy the repo to the target drive.
            --no-copy-keys # Do not copy SSH host keys (will cause problems with sops-nix!)
            --secure # Install assuming UEFI Secure boot will be in use.
        ]: nothing -> nothing {
            const SOPSFILE: path = "./.sops.yaml" 
            const SECRETS: path = "./lib/secrets.yaml"
            const ANCHOR: string = "\ncreation_rules"
            mut sopsfile: string = ""
            mut target_drive: path = ""
            mut keyfile: path = (mktemp)

            # Sanity checks: all of these are needed for an installation.
            use std assert
            assert ("./flake.nix" | path exists) "flake.nix not found. Where even are you..."
            assert ($SOPSFILE | path exists) ".sops.yaml not found."
            assert ($SECRETS | path exists) "secrets.yaml not found."
            assert ("~/.ssh/id_ed25519" | path exists) "SSH private key not found."
            assert ("~/.config/sops/age/keys.txt" | path exists) "Age private keys not found."

            # Run Disko.
            $"Running ($'disko (ansi green)--mode (ansi wb)($mode)' | code cyan)" | trace
            sudo disko --mode $mode --flake $"(realpath .)#($hostname)"

            # Copy needed hardware-related options from generated config.
            if not $ignore_generated_config {
                $"Copying options from ($'nixos-generate-config' | code blue)" | trace
                let options = sudo nixos-generate-config --root $mount --show-hardware-config
                    | lines
                    | where {|l| ($l | str downcase) =~ "boot"}
                    | where {|l| ($l | str downcase) =~ "module"}
                    | where {|l| ($l | str downcase) =~ "="}
                    | parse "{option} = {value};"

                for o in $options {
                    ${pkgs.sd}/bin/sd $'($o.option) = \[.*\]' $'($o.option) = ($o.value)' $"systems/($platform)\/($hostname)/default.nix"
                }
            };

            # Generate keys (so that sops-nix works fine).
            if not $no_copy_keys {
                $"Generating host ('SSH' | code blue) keys..." | trace

                let tmpdir = mktemp -d
                sudo mkdir -p $"($tmpdir)/etc/ssh"
                sudo ssh-keygen -A -f $tmpdir

                # Copy needed keys to systems/ and the target drive.
                sudo mkdir -p $"($mount)/etc/ssh"
                for type in ["ed25519" "rsa"] {
                    sudo cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"systems/($platform)\/($hostname)"
                    sudo cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key" $"($mount)/etc/ssh/"
                    sudo cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"($mount)/etc/ssh/"
                }

                $"Re-keying ('sops-nix' | code yellow)" | trace

                # The new host's key (should stay there).
                let age_pubkey = open $"($tmpdir)/etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age;
                add_sops_host_key --key $age_pubkey --host $hostname
                $sopsfile = (open --raw $SOPSFILE) # Save state without the installer's key.

                # The install ISO's key (should be removed).
                let installer_pubkey = open /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age;
                add_sops_host_key --key $installer_pubkey --host installer

                # Lock down the keys.
                sudo chmod 600 $"($mount)/etc/ssh/ssh_host_ed25519_key"
                sudo chmod 644 $"($mount)/etc/ssh/ssh_host_ed25519_key.pub"
                sudo chmod 600 $"($mount)/etc/ssh/ssh_host_rsa_key"
                sudo chmod 644 $"($mount)/etc/ssh/ssh_host_rsa_key.pub"
                sudo chown root:root $"($mount)/etc/ssh/ssh_host_ed25519_key"
                sudo chown root:root $"($mount)/etc/ssh/ssh_host_rsa_key"
            }

            if $secure {
                $"Creating UEFI Secure boot keys with ('sbctl' | code)" | trace
                do -i {
                    sudo sbctl create-keys
                    sudo cp -r /etc/secureboot /mnt/etc/
                }
            }

            # Run `nixos-install`.
            if $install {
                $"Running ('nixos-install' | code red)" | trace
                sudo nixos-install --no-root-password --root $mount --flake $".#($hostname)"
            }

            # WARN: Remove installer ISO's SSH key from sops-nix (if it was added).
            if not ($sopsfile | is-empty) {
                $"Removing installer ISO's keys from ($SOPSFILE | path basename | code green)" | trace
                $sopsfile | save -rf $SOPSFILE
            }

            # Copy the repo.
            if not $no_copy_repo {
                let repo: path = (pwd | path basename)
                let target = $"($mount)($copy_to)"
                cd ./..
                sudo cp --recursive $repo $target
                cd $repo
            }

            $"('aeon install' | code) is finished. Please check for any errors."                | trace
            $"If everything is alright, run ('sync' | code) and ($'umount -r ($mount)' | code)" | trace
            $"Then, you should be ready to reboot into the installed system."                   | trace
            $"(ansi green_bold)Good luck!(ansi reset)"                                          | trace

            # Update .sops.yaml with new host key.
            def add_sops_host_key [
                --key: string # Age public key to add.
                --host: string # The name of the host.
            ]: nothing -> nothing {
                if (${pkgs.ripgrep}/bin/rg $host $SOPSFILE | is-empty ) {
                    # Add a new key.
                    ${pkgs.sd}/bin/sd $ANCHOR $"\n  - &($host) ($key)($ANCHOR)" $SOPSFILE
                    $"      - *($host)\n" | save --append $SOPSFILE
                } else {
                    # Update an existing key.
                    ${pkgs.sd}/bin/sd $'&($host) \w*$' $'&($host) ($key)' $SOPSFILE
                }
                sops updatekeys $SECRETS
            }

            # Print a status message.
            def trace []: string -> nothing {
                print $"(ansi {fg: magenta, attr: b})aeon:(ansi reset) ($in)"
            }

            # Make a markdown-like code block.
            def code [
                fg: string = "cyan",
                attr: string = "n",
            ]: string -> string {
                $"(ansi {fg: $fg, bg: dark_gray, attr: $attr}) ($in) (ansi reset)"
            }
        }

        # Set a new wallpaper.
        def "${functionName} wp" [
            wallpaper: path # Path to the wallaper.
        ]: nothing -> nothing {
            ln --force --symbolic (realpath $wallpaper) ~/.wallpaper
            hyprctl --instance 0 reload
        }

        # Locate something in the nix store.
        #
        # Calls ${pkgs.nix-index}/bin/nix-locate under the hood.
        def "${functionName} locate" [
            pattern: string # What pattern to search for (regex).
        ]: nothing -> list<any> {
            ${pkgs.nix-index}/bin/nix-locate --regex $pattern
                | lines
                | parse "{output} {size} {letter} /nix/store/{store_hash}/{match}"
                | select output match
                | sort-by output
        }

        # Like which(1), but resolves symbolic links.
        def "${functionName} which" [
            binary: string # What binary to resolve.
        ]: nothing -> string {
            ${pkgs.coreutils}/bin/realpath (${lib.getExe pkgs.which} $binary)
                | lines
                | first
        }

        # List available fonts.
        def "${functionName} list-fonts" [
            --refresh-cache (-R), # Refresh the font cache first.
        ]: nothing -> list<any> {
            if $refresh_cache {
                ${pkgs.fontconfig}/bin/fc-cache --force --verbose
            }

            ${pkgs.fontconfig}/bin/fc-list
                | lines
                | parse "{store_path}: {name}:style={style}"
                | reject store_path
                | sort-by name
        }

        # Inspect ZFS filesystems, volumes and such.
        def "${functionName} zfs list" [
            --properties (-p): string = "name,mountpoint,type,avail,refer,used,usedsnap,compress,ratio,lused" # Which properties to show.
            --type (-t): string = "filesystem,volume" # Which types to display.
        ]: nothing -> table<any: any> {
            let data = zfs list -p -o all -t $type
                | lines
                | try { update 0 { str downcase } } catch { [""] }
                | to text
                | from ssv

            $data
                | update avail { try { into filesize } catch { 0b }}
                | update refer { try { into filesize } catch { 0b }}
                | update used  { try { into filesize } catch { 0b }}
                | update lused { try { into filesize } catch { 0b }}
                | update usedsnap { try { into filesize } catch { 0b }}
                | update ratio { try { into float } catch { 0.0 }}
                | select ...($properties | split row ',')
        }
    '';
}
