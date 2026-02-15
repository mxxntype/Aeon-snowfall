{ lib, ... }:

{
    options.aeon.meta = {
        battery-powered = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };
}
