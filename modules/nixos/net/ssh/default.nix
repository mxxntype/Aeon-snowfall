# INFO: SSH NixOS module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.net.ssh = {
        enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable SSH";
        };

        server = mkOption {
            type = with types; nullOr bool;
            default = null;
            description = "Whether allow SSH'ing into this machine (whether to run a server)";
        };
    };

    config = let
        inherit (config.aeon.net.ssh)
            enable
            server
            ;
    in mkMerge [
        {
            assertions = [
                {
                    assertion = (server != null);
                    message = ''
                        Please state explicitly whether to run an SSH server on the machine.
                        To do so, set the `aeon.net.ssh.server` option to `true` or `false`.
                    '';
                }
            ];
        }

        (mkIf (enable && server != null) {
            services.openssh = {
                enable = server;

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
            security.pam.sshAgentAuth.enable = true;

            programs = {
                # WARN: Common shells like Bash, Zsh and Fish will pick this up,
                # Nushell won't (userspace workaround available in home module).
                ssh.startAgent = true;

                # A replacement for interactive SSH terminals that allows roaming,
                # supports intermittent connectivity, and provides intelligent
                # local echo and line editing of user keystrokes.
                mosh = {
                    enable = true;
                    withUtempter = true;
                };
            };

            environment.systemPackages = with pkgs; [ sshfs ];
        })
    ];
}
