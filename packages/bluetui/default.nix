{
    inputs,
    pkgs,
    ...
}:

let
    inherit (inputs)
        fenix
        naersk
        ;

    toolchain = with fenix.packages.${pkgs.system};
    combine [
        minimal.rustc
        minimal.cargo
    ];

    naersk' = naersk.lib.${pkgs.system}.override {
        cargo = toolchain;
        rustc = toolchain;
    };
in

naersk'.buildPackage {
    src = "${inputs.bluetui}";
    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ dbus.dev ];
}
