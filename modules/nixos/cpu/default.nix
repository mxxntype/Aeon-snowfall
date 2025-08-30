{ lib, ... }:

{
    options.aeon.hardware.cpu = {
        type = lib.mkOption {
            type = lib.types.enum [ "amd" "intel" ];
        };
    };
}
