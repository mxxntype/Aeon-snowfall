{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
    pname = "cpx";
    version = "0.1.3";

    src = pkgs.fetchCrate {
        inherit pname version;
        hash = "sha256-Id+HHPnUUbpqaatU49DbSQ1lBBzjljE2nbjJyDiZYcc=";
    };

    cargoHash = "sha256-atEB43eB8btQfMXPTCfsZ6bbAUIPzF8lUELx0Rdul84=";
}
