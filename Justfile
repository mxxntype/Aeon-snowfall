default:
    @just --list

lint:
    nix run nixpkgs#typos
    nix run nixpkgs#deadnix
    nix run nixpkgs#statix check
