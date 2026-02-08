{ config, lib, ... }:

{
    config = let cfg = config.aeon.hardware.meta;
    in lib.mkIf cfg.laptop {
        hardware.brillo.enable = true;
    };
}
