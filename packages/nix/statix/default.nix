{ inputs, pkgs, ... }: let

unstable-pkgs = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

in unstable-pkgs.statix.overrideAttrs (_: rec {
    src = pkgs.fetchFromGitHub {
        owner = "oppiliappan";
        repo = "statix";
        rev = "e9df54ce918457f151d2e71993edeca1a7af0132";
        hash = "sha256-duH6Il124g+CdYX+HCqOGnpJxyxOCgWYcrcK0CBnA2M=";
    };

    cargoDeps = unstable-pkgs.rustPlatform.importCargoLock {
        lockFile = src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
    };
})
