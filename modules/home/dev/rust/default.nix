# INFO: Home-manager Rust module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.rust = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };

        type = mkOption {
            type = with types; nullOr (enum [ "rustup" "fenix" "rust-overlay" ]);
            default = "rustup";
        };
    };

    config = let
        inherit (config.aeon.dev.rust) enable type;
    in mkIf enable {
        aeon.dev.c.enable = true; # Rust needs a `cc` linker.
        home.packages = mkMerge [
            # Common cargo/rust packages.
            (with pkgs; [
                cargo-nextest    # Next-generation test runner for Rust projects.
                cargo-watch      # Watch over Cargo project's source
                cargo-info       # Show crates info from crates.io.
                cargo-deps       # Build dependency graphs of Rust projects.
                cargo-c          # Build and install C-compatible libraries.
                cargo-generate   # Generate a new Rust project by leveraging a git repository as a template.
                cargo-tauri      # Build smaller, faster, and more secure desktop applications with a web frontend.
                cargo-leptos     # A build tool for the Leptos web framework.
                leptosfmt        # A formatter for the leptos view! macro.
                cargo-binutils   # Invoke the LLVM tools shipped with the Rust toolchain.
                cargo-valgrind   # Runs valgrind and collects its output in a helpful manner.
                cargo-flamegraph # Easy flamegraphs for Rust projects and everything else, without Perl or pipes <3

                trunk      # Build, bundle & ship your Rust WASM application to the web.
                bacon      # Background rust code checker.
                diesel-cli # Database tool for working with projects that use Diesel.
                sqlx-cli   # SQLx's associated command-line utility.
                sccache    # Ccache with Cloud Storage.
            ])
            
            # Install rustup and let it do its thing.
            (mkIf (type == "rustup") (with pkgs; [ rustup ]))

            # Install Rust via the `fenix` flake. TODO
            (mkIf (type == "fenix") [ ])

            # Install Rust via the `rust-overlay` flake.
            (mkIf (type == "rust-overlay") (with pkgs; [
                rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
                    extensions = [ ];
                    targets = [ "wasm32-unknown-unknown" ];
                })
            ]))
        ];
    };
}
