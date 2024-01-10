{
    lib,
    ...
}:

with lib; {
    options.aeon.core = {
        enable = mkOption {
            description = "Whether to enable core NixOS options";
            type = types.bool;
            default = true;
        };
    };

    config = mkIf config.aeon.core.enable {
        # TODO
    };
}
