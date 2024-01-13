# INFO: SSH NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.ssh = {
        enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable SSH";
        };
    };

    config = mkIf config.aeon.ssh.enable {
        services.openssh = {
            enable = true;
            settings = {
                PasswordAuthentication = false;
                PermitRootLogin = "no";
                StreamLocalBindUnlink = "yes";    # Automatically remove stale sockets
            };
            # hostKeys = [
            #     {
            #         path = "/etc/ssh/ssh_host_ed25519_key";
            #         type = "ed25519";
            #     }
            # ];
        };

        programs = {
            ssh.startAgent = true;
            mosh = {
                enable = true;
                withUtempter = true;
            };
        };

        security.pam.enableSSHAgentAuth = true; # Passwordless sudo when SSH'ing with keys
        environment.systemPackages = with pkgs; [ sshfs ];
    };
}
