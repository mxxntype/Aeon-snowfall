{ inputs, pkgs, ... }:

if pkgs.stdenv.hostPlatform.system == "x86_64-linux"
then
    inputs.wiremix.packages.${pkgs.stdenv.hostPlatform.system}.default
else
    { }
