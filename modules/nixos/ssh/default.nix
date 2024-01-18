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

            # Basic hardening.
            settings = {
                PasswordAuthentication = mkDefault false;
                PermitRootLogin = mkDefault "no";
                StreamLocalBindUnlink = mkDefault "yes";
            };

            # NOTE: No clue if this is needed or not.
            # hostKeys = [
            #     {
            #         path = "/etc/ssh/ssh_host_ed25519_key";
            #         type = "ed25519";
            #     }
            # ];
        };

        # INFO: Passwordless sudo when SSH'ing with keys.
        #
        # FIXME: Turns out this is insecure.
        # https://github.com/NixOS/nixpkgs/issues/31611
        security.pam.enableSSHAgentAuth = true;

        programs = {
            # WARN: Common shells like Bash, Zsh and Fish will pick this up,
            # Nushell won't (userspace workaround available in home module)
            ssh.startAgent = true;

            # A replacement for interactive SSH terminals that allows roaming,
            # supports intermittent connectivity, and provides intelligent
            # local echo and line editing of user keystrokes.
            mosh = {
                enable = true;
                withUtempter = true;
            };
        };

        users.users = mkIf (builtins.hasAttr "${aeon.user}" config.home-manager.users) {
            ${aeon.user}.openssh = {
                authorizedKeys.keys = aeon.pubKeys;
            };
        };

        environment.systemPackages = with pkgs; [ sshfs ];
    };
}
