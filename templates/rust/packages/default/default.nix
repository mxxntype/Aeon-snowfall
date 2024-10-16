{
    inputs,
    pkgs,
    ...
}:

let
    toolchain = (pkgs.rustChannelOf {
        rustToolchain = ../../rust-toolchain.toml;
        # NOTE: This needs to be replaced whenever the Rust toolchain is updated.
        sha256 = "VZZnlyP69+Y3crrLHQyJirqlHrTtGTsyiSnZB8jEvVo=";
    }).rust;

    naersk' = pkgs.callPackage inputs.naersk {
        cargo = toolchain;
        rustc = toolchain;
    };
in

naersk'.buildPackage {
    src = ../..;
}
