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
            --partition (-p) # Partiton the target drive.
            --create-fs (-c) # Create FS on the target drive.
            --mount (-m): directory = /mnt # Where to mount the target drive.
            --install (-I) # Run nixos-install.
            --root-lv-size (-R): int = 100 # Size of the root LVM LV.(%)
            --ignore-generated-config (-i) # Do not automatically inherit `boot.*` options from `nixos-generate-config`.
            --BIOS (-B) # Use legacy BIOS boot instead of UEFI.
        ]: nothing -> nothing {
            if ($partition) {
                let target_drive = (select_blockdev --type "disk" --hint "installation drive")
                print $"Starting (ansi blue)fdisk(ansi reset) to partition target drive..."
                sudo ${pkgs.util-linux}/bin/fdisk $target_drive
            }

            if ($create_fs) {
                let root_part = (select_blockdev --type "part" --hint "root partition")

                let vg = $hostname
                print $"Setiing up (ansi blue_bold)LVM(ansi reset)..."
                sudo vgcreate $vg $root_part
                sudo lvcreate -n root -l $"($root_lv_size)%FREE" $vg

                print $"Creating (ansi default_bold)BTRFS(ansi reset) filesystem and subvolumes..."
                sudo ${pkgs.btrfs-progs}/bin/mkfs.btrfs $root_part -L $"($hostname)_btrfs" -q
                sudo mount $root_part $mount

                const subvolumes: list<string> = ["@" "@home" "@nix" "@persist"]
                let selected = ($subvolumes | input list --multi "What BTFS subvolumes to create")
                for sv in $selected {
                    sudo btrfs subvolume create $"($mount)/($sv)"
                }
                sudo umount -R $mount

                for sv in $selected {
                    let subdir = ($sv | str trim -c "@")
                    if not ($subdir | is-empty) { sudo mkdir $"($mount)/($subdir)" }
                    sudo mount $root_part $"($mount)/($subdir)" -o $"compress=zstd,space_cache=v2,subvol=($sv)"
                }

                if not ($BIOS) {
                    let efi_part = (select_blockdev --type "part" --hint "EFI partition")
                    sudo mkfs.fat -F 32 -n EFI $efi_part
                    sudo mkdir $"($mount)/boot"
                    sudo mkdir $"($mount)/boot/efi"
                    sudo mount $efi_part $"($mount)/boot/efi"
                }
            }

            if not ($ignore_generated_config) {
                let options = sudo nixos-generate-config --root $mount --show-hardware-config
                    | lines
                    | filter {|l| ($l | str downcase) =~ "boot"}
                    | filter {|l| ($l | str downcase) =~ "module"}
                    | filter {|l| ($l | str downcase) =~ "="}
                    | parse "{option} = {value};"

                let host_platform = (${pkgs.coreutils}/bin/uname -m)
                for o in $options {
                    ${pkgs.sd}/bin/sd $'($o.option) = \[.*\]' $'($o.option) = ($o.value)' $"systems/($host_platform)-linux/($hostname)/default.nix"
                }
            }

            if $install {
                print $"Running (ansi red)nixos-install(ansi reset)..."
                sudo ${pkgs.nixos-install-tools}/bin/nixos-install --root $mount --flake $".#($hostname)"
            }
        }

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
