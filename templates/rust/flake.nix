{
    description = "{{package-name}}";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        naersk.url = "github:nix-community/naersk";
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs: inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;
    };
}
