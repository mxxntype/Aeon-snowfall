# INFO: A more convenient installer ISO.

{
    pkgs,
    lib,
    ...
}:

{
    environment.systemPackages = with pkgs; [
        helix
        nushell
        sops
        ssh-to-age
        aeon.aeon
        disko
    ];

    programs.git = {
        enable = true;
        lfs.enable = true;
    };

    users.users.root = {
        openssh.authorizedKeys.keys = lib.aeon.pubKeys;
    };

    # Use NetworkManager.
    networking.wireless.enable = false;
    networking.networkmanager.enable = lib.mkForce true;

    # WARN: Removing this will cause the build to take forever.
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
    hardware.enableRedistributableFirmware = true;
}
