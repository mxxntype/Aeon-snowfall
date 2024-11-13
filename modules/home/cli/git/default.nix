# INFO: Home-manager Git module

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.git = {
        enable = mkOption {
            description = "Whether to enable Git VCS";
            type = types.bool;
            default = true;
        };
    };

    config = mkIf config.aeon.cli.git.enable {
        programs.git = {
            enable = true;
            userName = "mxxntype";
            userEmail = "59417007+mxxntype@users.noreply.github.com";

            extraConfig = {
                init.defaultBranch = "main";
                # Commit & tag signing
                gpg.format = "ssh";
                commit.gpgSign = true;
                tag.gpgSign = true;
                user.signingKey = "~/.ssh/id_ed25519.pub";
                gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
            };

            lfs.enable = true;
            difftastic = {
                enable = true;
                background = "dark";
            };
        };

        home.file.".ssh/allowed_signers".text = ''
            * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvBw3klXzVq5oTXtS061cfcGEjHWflPZNRBRg48N3w/ astrumaureus@Nox
        '';

        programs.gh = {
            enable = true;
            settings.git_protocol = "ssh";
            extensions = with pkgs; [
                gh-markdown-preview
            ];
        };

        home.packages = with pkgs; [
            git-filter-repo
            glab
            gitoxide
        ];

        # xdg.configFile."gh-dash/config.yml".text = ''
        #     theme:
        #         ui:
        #             table:
        #                 showSeparator: true
        #         colors:
        #             text:
        #                 primary: "#${colors.text}"
        #                 secondary: "#${colors.surface2}"
        #                 inverted: "#${colors.surface0}"
        #                 faint: "#${colors.surface2}"
        #                 warning: "#${colors.maroon}"
        #                 success: "#${colors.green}"
        #             background:
        #                 selected: "#${colors.surface0}"
        #             border:
        #                 primary: "#${colors.surface0}"
        #                 secondary: "#${colors.surface1}"
        #                 faint: "#${colors.surface0}"
        # '';
    };
}
