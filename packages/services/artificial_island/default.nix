{ inputs, pkgs, ... }: let

toolchain = with inputs.fenix.packages.${pkgs.system}; combine [
    minimal.cargo
    minimal.rustc
];

naersk' = pkgs.callPackage inputs.naersk {
    cargo = toolchain;
    rustc = toolchain;
};

in naersk'.buildPackage {
    src = pkgs.fetchFromGitHub {
        owner = "mxxntype";
        repo = "artificial_island";
        rev = "main";
        hash = "sha256-OivYJQxn3RkosOsy2SMrfqUHHJEDjW2HmBzztLDuWW0=";
    };

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl.dev libgcc.lib ];
}
