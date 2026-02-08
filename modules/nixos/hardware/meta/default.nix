{ lib, ... }:

{
    options.aeon.hardware.meta = {
        headless = lib.mkOption {
            type = lib.types.bool;
        };
        
        laptop = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };
}
