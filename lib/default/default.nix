{
    inputs,
    ...
}: let
    nix-std = builtins.attrValues inputs.nix-std.lib;
in {
    inherit nix-std;

    # INFO: I change my username from time to time,
    # An because some NixOS options inherit from from my Home-manager options,
    # I think it's quite reasonable to have my username declared as a variable.
    user = "mxxntype";
}
