# INFO: A tiny script for listing hardware devices grouped by their IOMMU group.
#
# Source: https://astrid.tech/2022/09/22/0/nixos-gpu-vfio

{
    pkgs,
    ...
}:

pkgs.writeShellScriptBin "iommugroups.sh" /* bash */ ''
    shopt -s nullglob
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        echo "IOMMU Group ''${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(${pkgs.pciutils}/bin/lspci -nns ''${d##*/})"
        done;
    done;
''
