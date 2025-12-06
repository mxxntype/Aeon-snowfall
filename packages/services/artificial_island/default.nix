{ inputs, pkgs, ... }: let

toolchain = with inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}; combine [
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
        hash = "sha256-IugH+oQaDQv0vWddoq4zmHHbRBBIWWichu8FSb1Bp4c=";
    };

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl.dev libgcc.lib ];
}
