{ pkgs, ... }:

pkgs.nil.overrideAttrs (_: rec {
    pname = "nil";
    version = "2025-09-07";
    src = pkgs.fetchFromGitHub {
        owner = "oxalica";
        repo = "nil";
        rev = "01e573c9e31ba3be7eaa848ba7dfcbd04260163e";
        hash = "sha256-ImGN436GYd50HjoKTeRK+kWYIU/7PkDv15UmoUCPDUk=";
    };

    cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
        allowBuiltinFetchGit = true;
    };
})
