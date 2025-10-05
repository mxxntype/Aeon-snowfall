# INFO: TUI for managing bluetooth devices.
#
# https://github.com/pythops/bluetui

{ inputs, pkgs, ... }: let

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

in naersk'.buildPackage {
    src = pkgs.fetchFromGitHub {
        owner = "pythops";
        repo = "bluetui";
        rev = "cdeb48d5e325aab0108a45e9e36dd7a2b5c7a5ee";
        hash = "sha256-iTpQylk2mWBJHmUO6vh0sYy4qdjHW6E4dp0pwGOXNys=";
    };

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ dbus.dev ];
}
