{
    description = "Aeon | NixOS flake";

    inputs = {
        # SECTION: Core inputs.
        nixpkgs.url = "github:mxxntype/nixpkgs/nixos-25.05";
        unstable.url = "github:mxxntype/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };


        # SECTION: Nix libraries.
        # Nix flake framework.
        snowfall-lib = {
            url = "github:mxxntype/snowfall";
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

        # Powerful cross-platform terminal emulator and multiplexer.
        wezterm.url = "github:wez/wezterm?dir=nix";

        wiremix = {
            url = "github:tsowell/wiremix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # NOTE: I manually package the Zen browser for myself.
        #
        # HACK: This does, however, mean that I will need to manually tweak the `version` here if I wish to update it.
        zen-browser-appimage = {
            url = "https://github.com/zen-browser/desktop/releases/download/1.13.2b/zen-x86_64.AppImage";
            flake = false;
        };

        # A fork of the Nix LSP server with support for the experimental `pipe-operators` feature.
        nil-fork.url = "github:q60/nil/pipe-operator-support";

        # A comfortable monospace font, my favourite.
        # NOTE: Used as an input for a custom build, see `packages/fonts/iosevka-aeon`.
        iosevka = { url = "github:be5invis/Iosevka/main"; flake = false; };


        # SECTION: My other flakes.
        helix-fork = {
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
        invar = {
            url = "github:exoumoon/invar";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        
        # SECTION: Non-flake inputs.
        csvlens = { url = "github:YS-L/csvlens"; flake = false; };
        bluetui = { url = "github:pythops/bluetui"; flake = false; };
        repalette = { url = "github:ziap/repalette"; flake = false; };
        srgn = { url = "github:alexpovel/srgn"; flake = false; };
        jfscan = { url = "github:nullt3r/jfscan"; flake = false; };
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
            xremap.nixosModules.default
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
