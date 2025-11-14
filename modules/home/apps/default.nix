{ lib, ... }:

{
    options.aeon.apps.defaultTerminal = lib.mkOption {
        type = lib.types.attrs;
        description = "(derivation) Which terminal to use by default";
    };
}
