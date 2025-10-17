{ config, lib, pkgs, ... }: with lib;

{
    options.aeon.dev.rust = {
        enable = mkOption {
            description = "Whether to install a Rust toolchain";
            default = true;
            type = types.bool;
        };

        type = mkOption {
            description = "Which way to install the Rust toolchain";
            default = "rustup";
            type = with types; nullOr (enum [
                "rustup"       # Install manually via the official Rust toolchain installer.
                "fenix"        # Automatic overlay #1. https://github.com/nix-community/fenix
                "rust-overlay" # Automatic overlay #1. https://github.com/oxalica/rust-overlay
            ]);
        };

        linker = mkOption {
            description = "Which linker to use for Rust projects";
            default = "default";
            type = types.enum [ "default" "mold" ];
        };
    };

    config = let
        inherit (config.aeon.dev.rust)
            enable
            type
            linker
            ;
    in mkIf enable (mkMerge [
        {
            # Rust needs a `cc` linker.
            # Could just add a single C compiler, but let's just enable the entire module either way.
            aeon.dev.c.enable = true;

            home.packages = mkMerge [
                # Common cargo/rust packages.
                (with pkgs; [
                    # Zero setup cross-compilation and cross-testing.
                    # https://github.com/cross-rs/cross#cross
                    cargo-cross

                    # Compile projects with zig as the linker.
                    # https://github.com/messense/cargo-zigbuild
                    cargo-zigbuild

                    # Next-generation test runner for Rust projects.
                    # https://github.com/nextest-rs/nextest
                    cargo-nextest

                    # Watch over Cargo project's source
                    # https://github.com/watchexec/cargo-watch
                    cargo-watch

                    # Build and install C-compatible libraries.
                    # https://github.com/lu-zero/cargo-c
                    cargo-c

                    # Generate a new Rust project by leveraging a git repository as a template.
                    # https://github.com/cargo-generate/cargo-generate
                    cargo-generate

                    # Build smaller, faster, and more secure desktop applications with a web frontend.
                    # https://tauri.app/
                    cargo-tauri

                    # A build tool for the Leptos web framework.
                    # https://github.com/leptos-rs/cargo-leptos
                    cargo-leptos

                    # A formatter for the leptos view! macro.
                    # https://github.com/bram209/leptosfmt
                    leptosfmt

                    # Invoke the LLVM tools shipped with the Rust toolchain.
                    # https://github.com/rust-embedded/cargo-binutils
                    cargo-binutils

                    # Runs valgrind and collects its output in a helpful manner.
                    # https://github.com/jfrimmel/cargo-valgrind
                    cargo-valgrind

                    # Easy flamegraphs for Rust projects and everything else, without Perl or pipes <3
                    # https://github.com/flamegraph-rs/flamegraph
                    cargo-flamegraph

                    # A tool for managing cargo workspaces and their crates.
                    # https://github.com/pksunkara/cargo-workspaces
                    # cargo-workspaces

                    # Scan your Rust crate for semver violations.
                    # https://github.com/obi1kenobi/cargo-semver-checks
                    cargo-semver-checks

                    # Configure Cargo profiles for best performance.
                    # https://github.com/kobzol/cargo-wizard
                    cargo-wizard

                    # Unformat code into perfect rectangles. WARN: Yes this is a meme.
                    # https://github.com/fprasx/cargo-unfmt
                    cargo-unfmt

                    # Audit your dependencies for crates with security vulnerabilities reported to the RustSec Advisory Database.
                    # https://github.com/rustsec/rustsec/tree/main/cargo-audit
                    cargo-audit

                    # Display when Rust dependencies are out of date.
                    # https://github.com/kbknapp/cargo-outdated
                    cargo-outdated

                    # Lists licenses of all dependencies.
                    # https://github.com/onur/cargo-license
                    cargo-license

                    # Show results of macro expansion.
                    # https://github.com/dtolnay/cargo-expand
                    cargo-expand

                    # Installing rust binaries as an alternative to building from source.
                    # https://github.com/cargo-bins/cargo-binstall
                    cargo-binstall

                    # Generate Debian packages from Rust projects.
                    # https://github.com/kornelski/cargo-deb
                    # BUG: Does not pass tests for some reason.
                    # cargo-deb

                    # Clean up unused build files generated by Cargo.
                    # https://github.com/holmgr/cargo-sweep
                    cargo-sweep

                    # Show a tree-like overview of a crate's modules.
                    # https://github.com/regexident/cargo-modules
                    cargo-modules

                    # Detect unused dependencies in Rust projects.
                    # https://github.com/bnjbvr/cargo-machete
                    cargo-machete

                    # https://github.com/mainmatter/cargo-autoinherit
                    # Automatically DRY up your Rust dependencies.
                    cargo-autoinherit

                    # https://github.com/sagiegurari/cargo-make
                    # Task runner and build tool.
                    cargo-make

                    bacon      # Background rust code checker.
                    diesel-cli # Database tool for working with projects that use Diesel.
                    dioxus-cli # Tool for developing, testing, and publishing Dioxus apps.
                    sccache    # Ccache with Cloud Storage.
                    sqlx-cli   # SQLx's associated command-line utility.
                    trunk      # Build, bundle & ship your Rust WASM application to the web.

                    wasm-bindgen-cli_0_2_104
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
        }

        # `mold` is a real fast as fuq linker (replacement for default `ld` or `lld`)
        (mkIf (linker == "mold") {
            home = {
                packages = with pkgs; [ mold-wrapped ];
                file.".cargo/config.toml".text = /* toml */ ''
                    [target.x86_64-unknown-linux-gnu]
                    rustflags = ["-C", "link-arg=-fuse-ld=mold"]
                '';
            };
        })
    ]);
}
