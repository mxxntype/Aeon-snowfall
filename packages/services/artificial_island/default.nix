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
        hash = "sha256-M87zbcpaVFZ5D32z58uh7qNZoMmbN37gS1AWiGxRwJ4=";
    };

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ openssl.dev libgcc.lib ];
}
