# List all available recipes.
default:
    @just --list

# Run a local Nix cache with nix-serve.
nix-serve LISTEN_ADDR:
    env NIX_SECRET_KEY_FILE=nix-serve/private.key nix run nixpkgs#nix-serve-ng -- -l {{LISTEN_ADDR}}:5000

# Generate a binary cache keypair.
generate-nix-serve-keypair DOMAIN:
    rm -f nix-serve/*.key
    nix-store --generate-binary-cache-key {{DOMAIN}} nix-serve/private.key nix-serve/public.key

# Run some static analysis tools.
lint:
    nix run nixpkgs#typos
    nix run .#statix -- check
    # ISSUE: These blow up with the new `pipe-operators` feature of Nix.
    # nix run nixpkgs#deadnix

# Perform a flake evaluation check.
check: lint
    nix flake check

# Run a package provided by this flake.
run PACKAGE:
    nix run .#packages.x86_64-linux.{{PACKAGE}}
