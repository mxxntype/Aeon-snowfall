{
    pkgs,
    ...
}:

pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    buildInputs = with pkgs; [
        cryptsetup
        util-linux
        efibootmgr
        btrfs-progs
        sbctl
        git
        home-manager
        helix
        nushell
        sops
        age
        ssh-to-age
        aeon.aeon
        disko
    ];
}
