# INFO: A Nushell script for managing and installing Aeon systems.
#
# WARNING: This derivation will produce a binany that will be recognized
# as "external" from within a Nushell shell (you get it), so you will get
# no shell completions and the output will be interpreted as a byte stream,
# even if it is actually a nushell data structure.

{ lib, pkgs, ... }:

pkgs.nuenv.writeScriptBin {
    name = "aeon";
    script = lib.aeon.nu-aeon.script {
        inherit pkgs;
        functionName = "main";
    };
}
