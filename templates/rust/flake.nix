{
    description = "{{description}}";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
        naersk.url = "github:nix-community/naersk";
        snowfall-lib = {
            url = "github:mxxntype/snowfall";
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
