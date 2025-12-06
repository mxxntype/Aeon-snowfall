{ inputs, pkgs, ... }:

inputs.siren.packages.${pkgs.stdenv.hostPlatform.system}.default
