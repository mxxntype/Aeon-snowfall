# INFO: Home-manager sops-nix module.

{
    config,
    lib,
    inputs,
    ...
}:

with lib; {
    # HACK: For some reason, importing it in flake.nix fails, but works here...
    imports = with inputs; [
        sops-nix.homeManagerModules.sops
    ];

    config = let
        inherit (config.xdg) configHome;
        keyFile = "${configHome}/sops/age/keys.txt";
    in {
        # Set up sops-nix and decrypt the age key.
        sops = {
            age = { inherit keyFile; };
            defaultSopsFile = ../../../lib/secrets.yaml;
            secrets."keys/age".path = keyFile;
        };
    };
}
