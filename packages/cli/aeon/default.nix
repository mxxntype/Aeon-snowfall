# INFO: A Nushell script for managing and installing Aeon systems.

{
    lib,
    pkgs,
    ...
}:

pkgs.nuenv.writeScriptBin {
    name = "aeon";
    script = /* nu */ ''
        # A Nushell script for managing and installing Aeon systems.
        def main []: nothing -> nothing {
            print $"(ansi green)note: (ansi reset)Run (ansi {fg: cyan, bg: dark_gray}) aeon --help (ansi reset) to see more options."
        }

        # Garbage-collect the system.
        def "main gc" []: nothing -> nothing {
            home-manager expire-generations 0
            sudo nix-collect-garbage -d
            nix store optimise
        }

        # Perform a system rebuild.
        def "main rebuild" [
            --flake (-f): directory = /home/${lib.aeon.user}/Aeon # Path to flake.
            --rebuild-system (-S) # Rebuilt the NixOS configuration.
            --rebuild-home (-H) # Rebuild the Home-manager configuration.
        ]: nothing -> nothing {
            if (not $rebuild_home) and (not $rebuild_system) {
                print $"(ansi red)note: (ansi reset)No action specified. Run with --help for options."
            }
            if $rebuild_home { home-manager switch --flake $flake }
            if $rebuild_system { sudo nixos-rebuild switch --flake $flake }
        }

        # Check the status of the VPN (and Tailscale).
        def "main vpn status" []: nothing -> record {
            {
                tailscale: (try { tailscale status | ignore; true } catch { false }),
                vpn: {
                    personal: ((systemctl is-active wg-quick-personal.service) == active),
                    invian: ((systemctl is-active wg-quick-invian.service) == active),
                }
            }
        }

        # Active the VPN service, if configured. Disables Tailscale.
        def "main vpn connect" [
            interface: string # The name of the interface to connect to.
        ]: nothing -> nothing {
            try {
                if ((systemctl is-active $"wg-quick-($interface)") != active) {
                    sudo systemctl start $"wg-quick-($interface)"
                    print $"(ansi green)STATUS:(ansi reset) Connecting to VPN, Tailscale is (ansi red)disabled(ansi reset) for now."
                } else {
                    print $"(ansi green)STATUS:(ansi reset) Already connected. Tailscale is (ansi red)disabled(ansi reset)."
                }
            } catch {
                print $"(ansi red)ERROR:(ansi reset) Can't interact with the VPN service. Is this one configured?"
            }
        }

        # Deactivate the VPN service, if configured. Re-enables Tailscale.
        def "main vpn disconnect" [
            interface: string # The name of the interface to disconnect from.
        ]: nothing -> nothing {
            try {
                if ((systemctl is-active $"wg-quick-($interface)") == active) {
                    sudo systemctl stop $"wg-quick-($interface)"
                    print $"(ansi green)STATUS:(ansi reset) Stopping the VPN, Tailscale is now (ansi green)active(ansi reset)."
                } else {
                    print $"(ansi green)STATUS:(ansi reset) Not yet connected. Tailscale is (ansi green)active(ansi reset)."
                }
            } catch {
                print $"(ansi red)ERROR:(ansi reset) Can't interact with the VPN service. Is this one configured?"
            }
        }

        # Run a QEMU VM with a NixOS system.
        def "main vm" [
            system: string = "illusion" # Which system to virtualize.
            --flake (-f): directory = "${lib.aeon.flakePath}" # Path to flake.
            --fresh (-F) # Delete ./<system>.qcow2 if found.
        ]: nothing -> nothing {
            if $fresh { do -ps { rm $"($system)" } }
            nixos-rebuild build-vm --flake $"($flake)\#($system)"
            exec $"./result/bin/run-($system)-vm"
        }

        # Perform a semi-automatic NixOS install using Disko.
        def "main install" [
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
            disko --mode $mode --flake $"(realpath .)#($hostname)"

            # Copy needed hardware-related options from generated config.
            if not $ignore_generated_config {
                $"Copying options from ($'nixos-generate-config' | code blue)" | trace
                let options = sudo nixos-generate-config --root $mount --show-hardware-config
                    | lines
                    | filter {|l| ($l | str downcase) =~ "boot"}
                    | filter {|l| ($l | str downcase) =~ "module"}
                    | filter {|l| ($l | str downcase) =~ "="}
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
                ssh-keygen -A -f $tmpdir

                # Copy needed keys to systems/ and the target drive.
                sudo mkdir -p $"($mount)/etc/ssh"
                for type in ["ed25519" "rsa"] {
                    cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"systems/($platform)\/($hostname)"
                    cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key" $"($mount)/etc/ssh/"
                    cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"($mount)/etc/ssh/"
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
                chmod 600 $"($mount)/etc/ssh/ssh_host_ed25519_key"
                chmod 644 $"($mount)/etc/ssh/ssh_host_ed25519_key.pub"
                chmod 600 $"($mount)/etc/ssh/ssh_host_rsa_key"
                chmod 644 $"($mount)/etc/ssh/ssh_host_rsa_key.pub"
                chown root:root $"($mount)/etc/ssh/ssh_host_ed25519_key"
                chown root:root $"($mount)/etc/ssh/ssh_host_rsa_key"
            }

            if $secure {
                $"Creating UEFI Secure boot keys with ('sbctl' | code)" | trace
                do -ps {
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
        def "main wp" [
            wallpaper: path # Path to the wallaper.
        ]: nothing -> nothing {
            # `swp` is my rust binary, but I don't want to compile it when
            # the script is used as an installer or something lightweight,
            # so I access it here directly, not through nix.
            swp $wallpaper
        }
    '';
}
