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
            --flake (-f): directory = /home/${lib.aeon.user}/Aeon # Path to flake.
            --home (-H) # Rebuild Home-manager only.
        ]: nothing -> nothing {
            match $home {
                true => (home-manager switch --flake $flake)
                false => (sudo nixos-rebuild switch --flake $flake)
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

        # Perform a semi-automatic NixOS install.
        def "main install" [
            hostname: string # Future hostname of the installed system.
            platform: string = "x86_64-linux" # Target platform (architecture).
            --partition (-p) # Partition the target drive.
            --create-fs (-c) # Create FS on the target drive.
            --mount (-m): directory = /mnt # Where to mount the target drive.
            --install (-I) # Run nixos-install.
            --BIOS (-B) # Use legacy BIOS boot instead of UEFI.
            --LUKS (-L) # Use LUKS2 encryption.
            --root-lv-size (-R): int = 100 # Size of the root LVM LV in %.
            --ignore-generated-config (-i) # Do not automatically inherit `boot.*` options from `nixos-generate-config`.
            --copy-to: directory = /home/${lib.aeon.user} # Where to copy the repo (in /mnt).
            --no-copy-repo # Do not copy the repo to the target drive.
            --no-copy-keys # Do not copy SSH host keys (will cause problems with sops-nix!)
        ]: nothing -> nothing {
            const SOPSFILE: path = "./.sops.yaml" 
            const SECRETS: path = "./lib/secrets.yaml"
            const ANCHOR: string = "\ncreation_rules"
            mut sopsfile: string = ""
            mut target_drive: path = ""
            mut keyfile: path = (mktemp)

            # Sanity checks: all of these are needed for an installation.
            use assert
            assert ("./flake.nix" | path exists) "flake.nix not found. Where even are you..."
            assert ($SOPSFILE | path exists) ".sops.yaml not found."
            assert ($SECRETS | path exists) "secrets.yaml not found."
            assert ("~/.ssh/id_ed25519" | path exists) "SSH private key not found."
            assert ("~/.config/sops/age/keys.txt" | path exists) "Age private keys not found."

            # Run `fdisk` to partition a drive.
            if $partition {
                $target_drive = (select_blockdev --type "disk" --hint "installation drive")
                print $"Starting (ansi blue)fdisk(ansi reset) to partition target drive..."
                sudo fdisk $target_drive
            }

            # TODO: Implement filesystems other than BTRFS.
            if $create_fs {
                mut root_part: path = ""
                
                if $LUKS {
                    print $"Setting up (ansi blue_bold)LUKS(ansi reset)..."

                    # Create the LUKS device.
                    let luks_part: path = (select_blockdev --type "part" --hint "LUKS partition")
                    let label: string = $"($hostname | str upcase)_LUKS"
                    cryptsetup luksFormat --label $label $luks_part

                    # Add a keyfile for single-passphrase boot.
                    dd if=/dev/urandom $"of=($keyfile)" bs=1024 count=4
                    cryptsetup luksAddKey $luks_part $keyfile

                    # Open the LUKS device.
                    let mapped_name: string = $"($hostname)-luks"
                    cryptsetup luksOpen $luks_part $mapped_name -d $keyfile
                    $root_part = $"/dev/mapper/($mapped_name)"
                } else {
                    # Pick a regular non-encrypted partition.
                    $root_part = (select_blockdev --type "part" --hint "root partition")
                }

                # Set up LVM.
                print $"Setting up (ansi blue_bold)LVM(ansi reset)..."
                sudo vgcreate $hostname $root_part
                sudo lvcreate -n root -l $"($root_lv_size)%FREE" $hostname
                let root_lv: path = $"/dev/($hostname)/root"

                # Create BTFS.
                print $"Creating (ansi blue_bold)BTRFS(ansi reset) filesystem and subvolumes..."
                sudo mkfs.btrfs $root_lv -L $"($hostname | str upcase)_BTRFS" -q
                sudo mount $root_lv $mount

                # Select & create subvolumes.
                const subvolumes: list<string> = ["@" "@home" "@nix" "@persist"]
                let selected = ($subvolumes | input list --multi "What BTFS subvolumes to create")
                for subvolume in $selected {
                    sudo btrfs subvolume create $"($mount)\/($subvolume)"
                }
                sudo umount -R $mount

                # Mount each subvolume with options.
                for subvolume in $selected {
                    let subdir: path = ($subvolume | str trim -c "@")
                    if not ($subdir | is-empty) { sudo mkdir -p $"($mount)\/($subdir)" }
                    sudo mount $root_lv $"($mount)\/($subdir)" -o $"compress=zstd,space_cache=v2,subvol=($subvolume)"
                }

                # Create a keyfile for LUKS.
                if $LUKS {
                    let secrets: directory = $"($mount)/etc/secrets/initrd"
                    ^mkdir -p $secrets
                    cp $keyfile $"($secrets)/keyfile-($hostname | str downcase).bin"
                    chmod 000 $keyfile
                    chattr +i $keyfile
                }

                # Create the UEFI partition if needed.
                if not $BIOS {
                    let efi_part: path = (select_blockdev --type "part" --hint "EFI partition")
                    sudo mkfs.fat -F 32 -n NIXOS_EFI $efi_part
                    sudo mkdir -p $"($mount)/boot/efi"
                    sudo mount $efi_part $"($mount)/boot/efi"
                }
            }

            # Copy needed hardware-related options from generated config.
            if not $ignore_generated_config {
                print $"Copying options from (ansi blue_bold)nixos-generate-config(ansi reset)..."
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
                print $"Generating host (ansi blue_bold)SSH(ansi reset) keys..."

                let tmpdir = mktemp -d
                sudo mkdir -p $"($tmpdir)/etc/ssh"
                ssh-keygen -A -f $tmpdir

                # Copy needed keys to systems/ and the target drive.
                sudo mkdir -p $"($mount)/etc/ssh"
                for type in ["ed25519" "rsa"] {
                    cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key.pub" $"systems/($platform)\/($hostname)"
                    sudo cp $"($tmpdir)/etc/ssh/ssh_host_($type)_key*" $"($mount)/etc/ssh/"
                }

                print $"Re-keying (ansi blue_bold)sops-nix(ansi reset)..."

                # The new host's key (should stay there).
                let age_pubkey = open $"($tmpdir)/etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age;
                add_sops_host_key --key $age_pubkey --host $hostname
                $sopsfile = (open --raw $SOPSFILE) # Save state without the installer's key.

                # The install ISO's key (should be removed).
                let installer_pubkey = open /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age;
                add_sops_host_key --key $installer_pubkey --host installer

                # Lock down the keys.
                sudo chmod 600 $"($mount)/etc/ssh/ssh_host_*_key"
                sudo chmod 644 $"($mount)/etc/ssh/ssh_host_*_key.pub"
                sudo chown root:root $"($mount)/etc/ssh/ssh_host_*_key*"
            }

            # Run `nixos-install`.
            if $install {
                print $"Running (ansi red)nixos-install(ansi reset)..."
                sudo nixos-install --no-root-password --root $mount --flake $".#($hostname)"
            }

            # WARN: Remove installer ISO's SSH key from sops-nix (if it was added).
            if not ($sopsfile | is-empty) {
                print $"(ansi red)Removing(ansi reset) installer ISO's SSH key from (ansi blue_bold)sops-nix(ansi reset)..."
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

            # Update .sops.yaml with new host key.
            def add_sops_host_key [
                --key: string # Age public key to add.
                --host: string # The name of the host.
            ]: nothing -> nothing {
                if (${pkgs.ripgrep}/bin/rg $host $SOPSFILE | is-empty ) {
                    # Add a new key.
                    ${pkgs.sd}/bin/sd $ANCHOR $"\n  - &($host) ($key)($ANCHOR)" $SOPSFILE
                    echo $"      - *($host)\n" | save --append $SOPSFILE
                } else {
                    # Update an existing key.
                    ${pkgs.sd}/bin/sd $'&($host) \w*$' $'&($host) ($key)' $SOPSFILE
                }
                sops updatekeys $SECRETS
            }

            # Pick a drive/partition from the ones available.
            def select_blockdev [
                --type: string # `disk` or `part`
                --hint: string # Hint of what's happening for the user.
            ]: nothing -> string {
                let lsblk = lsblk -JO | from json | get blockdevices
                let devices = ($lsblk | upsert children 0 | reject children) | append ($lsblk | get -i children | flatten) | filter {|d| not ($d | is-empty)}
                let target = $devices
                    | where type =~ $type
                    | select name path size model fstype
                    | input list --fuzzy $"Choose the (ansi blue)($hint)(ansi reset)"
                    | get path

                print $"Selected (ansi blue)($hint)(ansi reset): (ansi default_underline)($target)(ansi reset)"
                return $target
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
