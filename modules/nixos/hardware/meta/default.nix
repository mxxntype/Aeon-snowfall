{ lib, ... }:

{
    options.aeon.hardware.meta = {
        headless = lib.mkOption {
            type = lib.types.bool;
        };
    };
}
