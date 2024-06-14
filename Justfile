# List all available recipes.
default:
    @just --list

# Run some static analysis tools.
lint:
    nix run nixpkgs#typos
    nix run nixpkgs#deadnix
    nix run nixpkgs#statix -- check

# Perform a flake evaluation check.
check: lint
    nix flake check

# Run a package provided by this flake.
run PACKAGE:
    nix run .#packages.x86_64-linux.{{PACKAGE}}
