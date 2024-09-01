{
    inputs,
    pkgs,
    ...
}:

let
    toolchain = (pkgs.rustChannelOf {
        rustToolchain = ../../rust-toolchain.toml;
        sha256 = ""; # NOTE: Replace with actual SHA256!
    }).rust;

    naersk' = pkgs.callPackage inputs.naersk {
        cargo = toolchain;
        rustc = toolchain;
    };
in

naersk'.buildPackage {
    src = ../..;
}
