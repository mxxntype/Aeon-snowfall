{ pkgs, ... }:

pkgs.writeShellScriptBin "valgrind" ''
    ${pkgs.aeon.colour-valgrind}/bin/colour-valgrind $@
''
