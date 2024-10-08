{
    inputs,
    pkgs,
    ...
}:

inputs.invar.packages.${pkgs.system}.default
