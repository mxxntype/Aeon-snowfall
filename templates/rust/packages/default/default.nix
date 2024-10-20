{
    inputs,
    pkgs,
    lib,
    ...
}:

let
    toolchain = (pkgs.rustChannelOf {
        rustToolchain = ../../rust-toolchain.toml;
        # NOTE: This needs to be replaced whenever the Rust toolchain is updated.
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

    # Rust projects that have something to do with networking are very likely
    # to fail to compile if OpenSSL and pkg-config are unavailable at comptime.
    # NOTE: May also be unnecessary if the crate does no networking.
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ openssl ];
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
}
