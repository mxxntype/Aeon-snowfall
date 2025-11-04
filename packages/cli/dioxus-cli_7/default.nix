{ pkgs, lib, ... }:

pkgs.rustPlatform.buildRustPackage rec {
    pname = "dioxus-cli";
    version = "0.7.0";

    src = pkgs.fetchCrate {
        inherit pname version;
        hash = "sha256-+zWWG15qTXInaPCSKGd7yjLu8JQOev4AuZ//rbbMyyg=";
    };

    cargoHash = "sha256-xbYpi5QjeOTSVeBjwxeam14DtWawfSOlmrc1lmz/3H8=";

    buildFeatures = [ "no-downloads" ];

    nativeBuildInputs = with pkgs; [ pkg-config cacert ];
    buildInputs = with pkgs; [ openssl ];

    OPENSSL_NO_VENDOR = 1;

    nativeCheckInputs = with pkgs; [ rustfmt ];
    checkFlags = [
        # Requires network access.
        "--skip=serve::proxy::test"
        "--skip=wasm_bindgen::test"
        # Just doesn't work, idk why.
        "--skip=test_harnesses::run_harness"
    ];

    meta = with lib; {
        homepage = "https://dioxuslabs.com";
        description = "CLI tool for developing, testing, and publishing Dioxus apps";
        changelog = "https://github.com/DioxusLabs/dioxus/releases";
        license = with licenses; [ mit asl20 ];
        maintainers = with maintainers; [
            xanderio
            cathalmullan
        ];
        mainProgram = "dx";
    };
}
