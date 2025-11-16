{ inputs, pkgs, lib, ... }:

if pkgs.system == "x86_64-linux"
then
    inputs.wiremix.packages.${pkgs.system}.default
else
    { }
