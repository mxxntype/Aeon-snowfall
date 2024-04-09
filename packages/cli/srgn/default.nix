# INFO: A code surgeon for precise text and code transplantation.
#
# https://github.com/alexpovel/srgn

{
    inputs,
    pkgs,
    ...
}:

(pkgs.callPackage inputs.naersk {}).buildPackage {
    src = inputs.srgn;
}
