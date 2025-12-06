{ inputs, pkgs, ... }: let

rustWithWasiTarget = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-std" ];
    targets = [ "wasm32-wasip1" ];
};

craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustWithWasiTarget;

in craneLib.buildPackage {
    src = craneLib.cleanCargoSource inputs.zjstatus;
    cargoExtraArgs = "--target wasm32-wasip1";

    # HACK: Tests need to be run via `cargo wasi` which isn't in nixpkgs yet.
    # TODO(@mxxntype): Check, maybe that tool (whatever it is) is now available?
    doCheck = false;
    doNotSign = true;

    buildInputs =
        [ pkgs.libiconv ]
        ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ ];
}
