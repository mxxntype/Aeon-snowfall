{ inputs, pkgs, lib, ... }:

{
    environment = {
        systemPackages = with pkgs; [
            helix
            nushell
            sops
            ssh-to-age
            aeon.aeon
            disko
        ];

        # INFO: Includes a snapshot of this flake under `/etc/aeon-flake`.
        # The `.git` directory is not preserved, but this still may come
        # in handy one day.
        etc."aeon-flake".source = inputs.self;
    };

    programs.git = {
        enable = true;
        lfs.enable = true;
    };

    users.users.root = {
        openssh.authorizedKeys.keys = lib.aeon.pubKeys;
    };
    
    # HACK: Force-allow root login.
    services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

    aeon = {
        hardware = {
            cpu.type = "amd";
            meta.headless = false;
        };

        # BUG: `greetd` panics on startup, not sure why.
        # Well, not a big deal on an installer system.
        console.login-manager = "none";

        net = {
            networkmanager = false;
            ssh.server = true;
            tailscale.enable = false;
        };
    };

    # WARN: Removing this will cause the build to take forever.
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
    hardware.enableRedistributableFirmware = true;
}
