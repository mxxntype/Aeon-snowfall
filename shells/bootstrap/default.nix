{
    pkgs,
    ...
}:

pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    buildInputs = with pkgs; [
        aeon.aeon
        age
        btrfs-progs
        cryptsetup
        disko
        efibootmgr
        git
        helix
        home-manager
        nushell
        sbctl
        sops
        ssh-to-age
        util-linux
    ];
}
