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
        programs = {
            git = {
                enable = true;
                settings = {
                    user = {
                        name = "mxxntype";
                        email = "59417007+mxxntype@users.noreply.github.com";
                        signingKey = "~/.ssh/id_ed25519.pub";
                    };

                    init.defaultBranch = "main";
                    gpg.format = "ssh";
                    commit.gpgSign = true;
                    tag.gpgSign = true;
                    gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
                };

                lfs.enable = true;
            };

            difftastic = {
                enable = true;
                git.enable = true;
                options = {
                    tab-width = 4;
                };
            };

            gh = {
                enable = true;
                settings.git_protocol = "ssh";
                extensions = with pkgs; [
                    gh-markdown-preview
                ];
            };
        };

        home.file.".ssh/allowed_signers".text = ''
            * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvBw3klXzVq5oTXtS061cfcGEjHWflPZNRBRg48N3w/ astrumaureus@Nox
        '';

        home.packages = with pkgs; [
            git-filter-repo
            glab

            # Basically a git rewrite in Rust.
            gitoxide

            # A git-compatible DVCS that is both simple and powerful.
            jujutsu
        ];
    };
}
