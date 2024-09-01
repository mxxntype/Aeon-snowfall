{
    description = "";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        naersk.url = "github:nix-community/naersk";
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # INFO: Used to get the toolchain from the `rust-toolchain.toml` file.
        nixpkgs-mozilla = {
            url = "github:mozilla/nixpkgs-mozilla";
            flake = false;
        };
    };

    outputs = inputs: inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;

        overlays = with inputs; [ (import nixpkgs-mozilla) ];
    };
}
