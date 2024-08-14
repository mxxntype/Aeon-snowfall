# INFO: NixOS cryptography module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.crypto = {
        enable = mkOption {
            type = with types; bool;
            default = true;
            description = "Whether to enable cryptography support";
        };
    };

    config = let
        inherit (config.aeon.crypto)
            enable
            ;
    in mkIf enable {
        programs.gnupg.agent.enable = true;
        environment.systemPackages = with pkgs; [
            sops       # An editor of encrypted files (for `sops-nix`)
            ssh-to-age # Convert ED25519 SSH private keys to age keys.
            age        # Modern encryption tool with small explicit keys. (Go version)
            rage       # Modern encryption tool with small explicit keys. (Rust version)
            cryptsetup # LUKS for dm-crypt.
        ];
    };
}
