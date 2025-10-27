{ inputs, pkgs, ... }: let

toolchain = with inputs.fenix.packages.${pkgs.system}; combine [
    minimal.cargo
    minimal.rustc
];

naersk' = pkgs.callPackage inputs.naersk {
    cargo = toolchain;
    rustc = toolchain;
};

in naersk'.buildPackage rec {
    name = "artificial_island";
    version = "git";
    src = pkgs.fetchFromGitHub {
        owner = "mxxntype";
        repo = name;
        rev = "main";
        hash = "sha256-Yn2p9Do4ykfF/qPVxakhQxc6sTWE6aUiLGtbapU1r6U=";
    };

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl.dev libgcc.lib ];
}
