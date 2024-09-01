{
    description = "Aeon | NixOS flake";

    inputs = {
        # SECTION: Core inputs.
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
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

        # Generate infrastructure and network diagrams directly from your NixOS configurations.
        nix-topology = {
            url = "github:oddlama/nix-topology";
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

        # Pure and reproducible nix overlay of binary distributed rust toolchains.
        # (Alternative to Fenix)
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Cargo build systems for Nix.
        naersk.url = "github:nix-community/naersk";
        crane = {
            url = "github:ipetkov/crane";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        # An experimental Nushell environment for Nix.
        nuenv = {
            url = "github:DeterminateSystems/nuenv";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Hyprland and plugins.
        #
        # Hyprland *really* cares about matching versions of everything, so to be sure these are with tags.
        # The wacky URL is because of https://github.com/hyprwm/Hyprland/issues/5891#issuecomment-2094865630.
        hyprland.url = "git+https://github.com/hyprwm/Hyprland.git?ref=refs/tags/v0.41.0&submodules=1";
        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins";
            inputs.hyprland.follows = "hyprland";
        };
        hyprland-hy3 = {            
            url = "github:outfoxxed/hy3?ref=hl0.41.0";
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
        helix = {
            url = "github:mxxntype/helix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        siren = {
            url = "github:mxxntype/siren";
            inputs.nixpkgs.follows = "nixpkgs";
        };
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
        swp = {
            url = "git+ssh://git@github.com/mxxntype/swp.git";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                snowfall-lib.follows = "snowfall-lib";
            };
        };

        
        # SECTION: Non-flake inputs.
        csvlens = {
            url = "github:YS-L/csvlens";
            flake = false;
        };
        bluetui = {
            url = "github:pythops/bluetui";
            flake = false;
        };
        repalette = {
            url = "github:ziap/repalette";
            flake = false;
        };
        srgn = {
            url = "github:alexpovel/srgn";
            flake = false;
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
            hyprland.nixosModules.default
            # nix-topology.nixosModules.default
        ];

        # Overlays for Nixpkgs.
        overlays = with inputs; [
            nuenv.overlays.nuenv
            fenix.overlays.default
            rust-overlay.overlays.default
            swp.overlays."package/swp"
            # nix-topology.overlays.default
        ];

        templates = {
            rust = {
                path = ./templates/rust;
                description = "Rust crate template for cargo-generate";
            };
        };

        alias = {
            shells.default = "bootstrap";
            packages.default = "aeon";
        };

        # NOTE: An example for future self.
        # outputs-builder = channels: {
        #     topology = import inputs.nix-topology {
        #         pkgs = channels.nixpkgs;
        #         modules = [
        #             { inherit (outputs) nixosConfigurations; }
        #         ];
        #     };
        # };
    };
}
