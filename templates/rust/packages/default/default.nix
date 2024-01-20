{
    inputs,
    pkgs,
    ...
}:

(pkgs.callPackage inputs.naersk {}).buildPackage {
    src = ../..;
}
