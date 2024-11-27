{
    inputs,
    pkgs,
    lib,
    ...
}:

let
    toolchain = (pkgs.rustChannelOf {
        # NOTE: This needs to be tweaked whenever the Rust toolchain is updated.
        rustToolchain = ../../rust-toolchain.toml;
        sha256 = "yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
    }).rust;

    naersk' = pkgs.callPackage inputs.naersk {
        cargo = toolchain;
        rustc = toolchain;
    };
in

naersk'.buildPackage rec {
    src = ../..;
    pname = "{{project-name}}";

    # Rust projects that have something to do with networking are likely
    # to fail to compile if OpenSSL and pkg-config are not unavailable.
    # NOTE: May also be unnecessary if the crate does no networking.
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ openssl ];
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
}
