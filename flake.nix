{
    description = "Aeon | NixOS flake";

    inputs = {
        # SECTION: Core inputs.
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Nix libraries.
        # Nix flake framework.
        snowfall-lib = {
            url = "github:mxxntype/snowfall";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # INFO: https://determinate.systems
        determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

        # Standalone library for the Nix language.
        nix-std.url = "github:chessai/nix-std";

        # Atomic secret provisioning for NixOS.
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

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

        # Pure and reproducible nix overlay of binary distributed rust toolchains.
        # (Alternative to Fenix)
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Cargo build systems for Nix.
        naersk.url = "github:nix-community/naersk";
        crane.url = "github:ipetkov/crane";
        
        # An experimental Nushell environment for Nix.
        nuenv = {
            url = "github:DeterminateSystems/nuenv";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # SECTION: Hyprland and plugins.
        #
        # Hyprland *really* cares about matching versions of everything, so to be sure these are with tags.
        # The wacky URL is because of https://github.com/hyprwm/Hyprland/issues/5891#issuecomment-2094865630.
        # NOTE: The hyprland's `package` is (for now) the one provided by `nixpgks`, not the one from here.
        hyprland = {
            url = "git+https://github.com/hyprwm/Hyprland.git?ref=refs/tags/v0.44.0&submodules=1";
            inputs.hyprutils.follows = "hyprutils";
        };
        # NOTE: Due to *something*, Hyprland's derivation gets an old and incompatible version of `hyprutils`
        # and fails to build. Perhaps that will be resolved with an update or something, but for now explicitly
        # pinning this to a tag and overriding `hyprland`'s corresponding input seems to fix the build.
        hyprutils = {
            url = "github:hyprwm/hyprutils?ref=v0.2.3";
        };
        hyprland-plugins = {
            url = "github:hyprwm/hyprland-plugins?ref=v0.44.0";
            inputs.hyprland.follows = "hyprland";
        };
        hyprland-hy3 = {            
            url = "github:outfoxxed/hy3?ref=hl0.44.0";
            inputs.hyprland.follows = "hyprland";
        };
        hyprland-contrib = {
            url = "github:hyprwm/contrib";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Desktop/IO stuff.
        xremap = {
            url = "github:xremap/nix-flake";
            inputs.crane.follows = "crane";
            inputs.home-manager.follows = "home-manager";
            inputs.hyprland.follows = "hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Toolkit for building status bars, widgets, lockscreens, and other desktop components using QtQuick.
        quickshell = {
            url = "git+https://git.outfoxxed.me/quickshell/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Misc flakes.
        # A nice and configurable Zellij statusbar.
        zjstatus = {
            url = "github:dj95/zjstatus";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # A neat TUI for pipewire.
        wiremix = {
            url = "github:tsowell/wiremix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # My own Wake-on-LAN tool.
        siren = {
            url = "github:mxxntype/siren";
            inputs.naersk.follows = "naersk";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.snowfall-lib.follows = "snowfall-lib";
        };

        # A CLI tool for managing modded minecraft servers.
        invar = {
            url = "github:exoumoon/invar";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.snowfall-lib.follows = "snowfall-lib";
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
            determinate.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
            hyprland.nixosModules.default
            xremap.nixosModules.default
            # nix-topology.nixosModules.default
        ];

        # Overlays for Nixpkgs.
        overlays = with inputs; [
            nuenv.overlays.nuenv
            fenix.overlays.default
            rust-overlay.overlays.default
            # nix-topology.overlays.default
        ];

        templates = {
            rust = {
                path = ./templates/rust;
                description = "Rust crate template for cargo-generate";
            };

            typst = {
                path = ./templates/typst;
                description = "Typst paper template for writing neat documents";
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
