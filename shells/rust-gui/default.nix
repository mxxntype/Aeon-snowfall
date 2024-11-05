# INFO: A shell for running Rust GUIs on NixOS.
#
# No GPU / GUI / Gamedev Rust-powered libraries and engines that I've tried worked
# on NixOS, neither with X11 nor Wayland. However, it seems to work in this shell.
# SOURCE: https://github.com/bevyengine/bevy/issues/9203#issuecomment-1657248743

{
    pkgs,
    lib,
    ...
}:

pkgs.mkShell rec {
    nativeBuildInputs = with pkgs; [
        pkg-config
        nasm
        perl
        cmake
    ];

    buildInputs = with pkgs; [
        # Common.
        udev
        alsa-lib
        vulkan-loader
        libGL
        gtk3
        # X11.
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        # Wayland.
        libxkbcommon
        wayland
    ];

    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
