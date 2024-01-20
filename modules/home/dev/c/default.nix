# INFO: Home-manager C/C++ module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.c = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = mkIf config.aeon.dev.c.enable {
        home.packages = with pkgs; [
            gcc
            gdb
            clang
            clang-tools
            cppcheck
            valgrind
        ];
    };
}
