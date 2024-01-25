# INFO: A move convenient installer ISO.

{
    pkgs,
    lib,
    ...
}:

{
    networking.networkmanager.enable = lib.mkForce false; # HACK: Does not evaluate otherwise.
    environment.systemPackages = with pkgs; [
        helix
        nushell
        sops
        ssh-to-age
        aeon.aeon
    ];

    programs.git = {
        enable = true;
        lfs.enable = true;
    };

    users.users.root = {
        openssh.authorizedKeys.keys = lib.aeon.pubKeys;
    };

    # WARN: Removing this will cause the build to take forever.
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
}
