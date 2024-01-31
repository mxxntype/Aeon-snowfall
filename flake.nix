{
    description = "Aeon | NixOS flake";

    inputs = {
        # SECTION: Core inputs.
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Nix libraries.
        # Nix flake framework.
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Standalone library for the Nix language.
        nix-std.url = "github:chessai/nix-std";

        # Atomic secret provisioning for NixOS.
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Persistent state on systems with ephemeral root storage.
        impermanence.url = "github:nix-community/impermanence";

        # Collection of image builders.
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Declarative disk partitioning and formatting using Nix.
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Hardware.
        # Lanzaboote, UEFI secure boot for NixOS.
        lanzaboote = {
            url = "github:nix-community/lanzaboote";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # NixOS modules covering hardware quirks.
        hardware.url = "github:nixos/nixos-hardware";


        # SECTION: Nix libraries for building stuff.
        # Rust toolchains and rust-analyzer nightly.
        fenix = {
            url = "github:nix-community/fenix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Cargo build system for Nix.
        naersk.url = "github:nix-community/naersk";
        
        # An experimental Nushell environment for Nix.
        nuenv = {
            url = "github:DeterminateSystems/nuenv";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Hyprland and plugins.
        hyprland.url = "github:hyprwm/Hyprland";
        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins";
            inputs.hyprland.follows = "hyprland";
        };
        hyprland-hy3 = {            
            url = "github:outfoxxed/hy3";
            inputs.hyprland.follows = "hyprland";
        };
        hyprland-contrib = {
            url = "github:hyprwm/contrib";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Misc flakes.
        # A nice and configurable Zellij statusbar.
        zjstatus = {
            url = "github:dj95/zjstatus";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: My other flakes.
        hyprquery = {
            url = "github:mxxntype/hyprquery";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        reddot = {
            url = "github:mxxntype/reddot";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        ndrs = {
            url = "git+ssh://git@github.com/mxxntype/ndrs.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs: inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;

        # Snowfall Lib configuration.
        snowfall = {
            namespace = "aeon";
            meta = {
                name = "aeon";
                title = "Aeon | NixOS flake";
            };
        };

        channels-config = {
            allowUnfree = true;
            permittedInsecurePackages = [ ];
        };

        # Global NixOS modules.
        systems.modules.nixos = with inputs; [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
        ];

        # Global home-manager modules.
        # homes.modules = with inputs; [
            # sops-nix.homeManagerModules.sops
            # hyprland.homeManagerModules.default
        # ];

        # Overlays for Nixpkgs.
        overlays = with inputs; [
            nuenv.overlays.nuenv
            fenix.overlays.default
        ];

        templates = {
            rust = {
                path = ./templates/rust;
                description = "Rust crate template for cargo-generate";
            };
        };
    };
}
