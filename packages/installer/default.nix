{
    pkgs,
    ...
}:

pkgs.nuenv.writeScriptBin {
    name = "aeon-installer";
    script = /* nu */ ''
        def main [
            --partition (-p) # Partiton the target drive.
            --create-fs (-c) # Create FS on the target drive.
            --hostname (-H): string # Future hostname of the installed system.
            --mount (-m): directory = /mnt # Where to mount the target drive.
            --ignore-generated-config (-i) # Do not automatically inherit `boot.*` options from `nixos-generate-config`
        ]: nothing -> nothing {
            if ($partition) {
                let target_drive = (select_blockdev --type "disk" --hint "installation drive")
                print $"Starting (ansi blue)fdisk(ansi reset) to partition target drive..."
                sudo ${pkgs.util-linux}/bin/fdisk $target_drive
            }

            if ($create_fs) {
                let root_part = (select_blockdev --type "part" --hint "root partition")

                print $"Creating (ansi default_bold)BTRFS(ansi reset) filesystem and subvolumes..."
                sudo ${pkgs.btrfs-progs}/bin/mkfs.btrfs $root_part -L $"($hostname)_btrfs" -q
                sudo mount $root_part $mount

                const subvolumes: list<string> = ["@" "@home" "@nix" "@persist"]
                for sv in ($subvolumes | input list --multi "What BTFS subvolumes to create") {
                    sudo btrfs subvolume create $"($mount)/($sv)"
                }
                sudo umount -R $mount

                for sv in $subvolumes {
                    let subdir = ($sv | str trim -c "@")
                    if not ($subdir | is-empty) { sudo mkdir $"($mount)/($subdir)" }
                    sudo mount $root_part $"($mount)/($subdir)" -o $"compress=zstd,space_cache=v2,subvol=($sv)"
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
