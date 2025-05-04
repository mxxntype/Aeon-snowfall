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
            clang-tools
            cppcheck
            gcc
            gdb
            openssl
            openssl.dev
            pkg-config
            valgrind
        ];
    };
}
