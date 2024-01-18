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
        def main []: nothing -> nothing {}

        # Garbage-collect the system.
        def "main gc" []: nothing -> nothing {
            home-manager expire-generations 0
            sudo nix-collect-garbage -d
            nix store optimise
        }

        # Perform a system rebuild.
        def "main rebuild" [
            --flake (-f): directory = /home/${lib.aeon.user}/Aeon # Path to flake
            --home (-H) # Rebuild Home-manager only
        ]: nothing -> nothing {
            match $home {
                true => (home-manager switch --flake $flake)
                false => (sudo nixos-rebuild switch --flake $flake)
            }
        }

        # Perform a semi-automatic NixOS install.
        def "main install" [
            hostname: string # Future hostname of the installed system.
            platform: string = "x86_64-linux" # Target platform (architecture).
            --partition (-p) # Partiton the target drive.
            --create-fs (-c) # Create FS on the target drive.
            --mount (-m): directory = /mnt # Where to mount the target drive.
            --install (-I) # Run nixos-install.
            --BIOS (-B) # Use legacy BIOS boot instead of UEFI.
            --root-lv-size (-R): int = 100 # Size of the root LVM LV in %.
            --ignore-generated-config (-i) # Do not automatically inherit `boot.*` options from `nixos-generate-config`.
            --copy-to: directory = /home/${lib.aeon.user} # Where to copy the repo (in /mnt).
            --no-copy-repo # Do not copy the repo to the target drive.
            --no-copy-keys # Do not copy SSH host keys (will cause problems with sops-nix!)
        ]: nothing -> nothing {
            # Run `fdisk` to partition a drive.
            if ($partition) {
                let target_drive = (select_blockdev --type "disk" --hint "installation drive")
                print $"Starting (ansi blue)fdisk(ansi reset) to partition target drive..."
                sudo ${pkgs.util-linux}/bin/fdisk $target_drive
            }

            # TODO: Implement filesystems other than BTRFS.
            if ($create_fs) {
                let root_part = (select_blockdev --type "part" --hint "root partition")

                # Set up LVM.
                print $"Setting up (ansi blue_bold)LVM(ansi reset)..."
                sudo vgcreate $hostname $root_part
                sudo lvcreate -n root -l $"($root_lv_size)%FREE" $hostname
                let root_lv = $"/dev/($hostname)/root"

                # Create BTFS.
                print $"Creating (ansi default_bold)BTRFS(ansi reset) filesystem and subvolumes..."
                sudo ${pkgs.btrfs-progs}/bin/mkfs.btrfs $root_lv -L $"($hostname)_btrfs" -q
                sudo mount $root_lv $mount

                # Select & create subvolumes.
                const subvolumes: list<string> = ["@" "@home" "@nix" "@persist"]
                let selected = ($subvolumes | input list --multi "What BTFS subvolumes to create")
                for subvolume in $selected {
                    sudo btrfs subvolume create $"($mount)/($subvolume)"
                }
                sudo umount -R $mount

                # Mount each subvolume with options.
                for subvolume in $selected {
                    let subdir = ($subvolume | str trim -c "@")
                    if not ($subdir | is-empty) { sudo mkdir $"($mount)/($subdir)" }
                    sudo mount $root_lv $"($mount)/($subdir)" -o $"compress=zstd,space_cache=v2,subvol=($subvolume)"
                }

                # Create the UEFI partition if needed.
                if not ($BIOS) {
                    let efi_part = (select_blockdev --type "part" --hint "EFI partition")
                    sudo mkfs.fat -F 32 -n EFI $efi_part
                    sudo mkdir $"($mount)/boot"
                    sudo mkdir $"($mount)/boot/efi"
                    sudo mount $efi_part $"($mount)/boot/efi"
                }
            }

            # Copy needed hardware-related options from generated config.
            if not ($ignore_generated_config) {
                let options = sudo nixos-generate-config --root $mount --show-hardware-config
                    | lines
                    | filter {|l| ($l | str downcase) =~ "boot"}
                    | filter {|l| ($l | str downcase) =~ "module"}
                    | filter {|l| ($l | str downcase) =~ "="}
                    | parse "{option} = {value};"

                for o in $options {
                    ${pkgs.sd}/bin/sd $'($o.option) = \[.*\]' $'($o.option) = ($o.value)' $"systems/($platform)/($hostname)/default.nix"
                }
            };

            # Generate keys (so that sops-nix works fine).
            if not $no_copy_keys {
                let tmpdir = mktemp -d
                mkdir $"($tmpdir)/etc/ssh"
                ${pkgs.openssh}/bin/ssh-keygen -A -f $tmpdir

                # Copy needed keys to systems/ and the target drive.
                sudo mkdir -v $"($mount)/etc/ssh"
                for type in ["ed25519" "rsa"] {
                    cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"systems/($platform)/($hostname)"
                    sudo cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key*" $"($mount)/etc/ssh/"
                }

                # Update .sops.yaml with new host key.
                const SOPSFILE: path = "./.sops.yaml" 
                const SECRETS: path = "./lib/secrets.yaml"
                const ANCHOR: string = "\ncreation_rules"
                let age_pubkey = open $"($tmpdir)/etc/ssh/ssh_host_ed25519_key.pub"
                    | ${pkgs.ssh-to-age}/bin/ssh-to-age
                ${pkgs.sd}/bin/sd $ANCHOR $"\n    - &($hostname) ($age_pubkey)($ANCHOR)" $SOPSFILE
                echo $"      - *($hostname)" | save --append $SOPSFILE
                sops updatekeys $SECRETS

                # Lock down the keys.
                sudo chmod 600 $"($mount)/etc/ssh/*"
                sudo chmod 644 $"($mount)/etc/ssh/*.pub"
                sudo chown root:root $"($mount)/etc/ssh/*"
            }

            # Run `nixos-install`.
            if $install {
                print $"Running (ansi red)nixos-install(ansi reset)..."
                sudo ${pkgs.nixos-install-tools}/bin/nixos-install --root $mount --flake $".#($hostname)"
            }

            # Copy the repo.
            if not $no_copy_repo {
                const REPO: string = "Aeon-snowfall"; # FIXME: Rename to `Aeon` when merged
                let target = $"($mount)($copy_to)"
                cd ./..
                sudo cp --recursive $REPO $target
                sudo chmod ${lib.aeon.user}:wheel $target -R
                cd $REPO
            }
        };

        # Pick a drive/partition from the ones available.
        def select_blockdev [
            --type: string # `disk` or `part`
            --hint: string # Hint of what's happening for the user.
        ]: nothing -> string {
            let lsblk = ${pkgs.util-linux}/bin/lsblk -JO | from json | get blockdevices
            let devices = ($lsblk | upsert children 0 | reject children) | append ($lsblk | get -i children | flatten) | filter {|d| not ($d | is-empty)}
            let target = $devices
                | where type =~ $type
                | select name path size model fstype
                | input list --fuzzy $"Choose the (ansi blue)($hint)(ansi reset)"
                | get path

            print $"Selected (ansi blue)($hint)(ansi reset): (ansi default_underline)($target)(ansi reset)"
            return $target
        }
    '';
}
