{
    inputs,
    ...
}: let
    nix-std = builtins.attrValues inputs.nix-std.lib;
in {
    inherit nix-std;
}
