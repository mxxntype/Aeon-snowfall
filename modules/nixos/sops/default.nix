# INFO: NixOS sops-nix module.

{
    config,
    lib,
    ...
}:

with lib; {
    config = {
        sops = {
            defaultSopsFile = mkDefault ../../../lib/secrets.yaml;
            age.keyFile = "${config.home-manager.users.${lib.aeon.user}.xdg.configHome}/sops/age/keys.txt";
        };
    };
}
