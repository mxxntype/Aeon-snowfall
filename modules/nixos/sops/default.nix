# INFO: NixOS sops-nix module.

{
    config,
    lib,
    ...
}:

with lib; {
    config = {
        sops.defaultSopsFile = mkDefault ../../../lib/secrets.yaml;
    };
}
