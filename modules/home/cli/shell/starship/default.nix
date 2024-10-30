# INFO: Home-manager module for Starship, the minimal, blazing-fast, and infinitely customizable prompt for any shell.

{
    config,
    lib,
    ...
}:

with lib;

{
    options.aeon.cli.shell.starship = {
        enable = mkOption {
            type = with types; bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.cli.shell.starship)
            enable
            ;
        inherit (config.aeon.theme)
            colors
            ui
            ;
    in mkIf enable {
        programs.starship = {
            enable = true;
            settings = let
                # NOTE: Shortcut for adding dark-gray square brackets around a block.
                mkContainer = contents: "[\\[](fg:#${ui.bg.surface2})${contents}[\\]](fg:#${ui.bg.surface2}) ";
            in {
                add_newline = false;

                username = {
                    style_user = "bold purple";
                    style_root = "bold red";
                    aliases = { "${lib.aeon.user}" = "󰼁"; };
                    format = " [$user]($style) ";
                };

                hostname = {
                    ssh_only = true;
                    ssh_symbol = "󰑔 ";
                    style = "bold blue";
                    format = mkContainer "(fg:white)[$ssh_symbol$hostname]($style)";
                };

                directory = {
                    format = "[󰉋 $path]($style)[$read_only]($read_only_style) ";
                };

                character = let style = "bold fg:#${ui.fg.subtext1}"; in {
                    success_symbol = "[~>](${style})";
                    error_symbol = "[~>](${style})";
                };

                git_branch = {
                    format = mkContainer "[$symbol$branch(:$remote_branch)]($style)";
                    symbol = "󰘬 ";
                };

                rust = {
                    format = mkContainer "[$symbol$numver ($toolchain)]($style)";
                    symbol = "󱘗";
                    style = "fg:#${colors.peach}";
                };

                # PERF: This does not affect the nix3 shell (`nix shell`),
                # however noticeably slows down the whole environment.
                nix_shell.disabled = true;

                cmd_duration.disabled = true;
                git_status.disabled = true;

                format = builtins.replaceStrings [ "\n" ] [ "" ] ''
                    $hostname
                    $localip
                    $shlvl
                    $singularity
                    $kubernetes
                    $directory
                    $vcsh
                    $fossil_branch
                    $fossil_metrics
                    $git_branch
                    $git_commit
                    $git_state
                    $git_metrics
                    $git_status
                    $hg_branch
                    $pijul_channel
                    $docker_context
                    $c
                    $cmake
                    $cobol
                    $daml
                    $dart
                    $deno
                    $dotnet
                    $elixir
                    $elm
                    $erlang
                    $fennel
                    $gleam
                    $golang
                    $guix_shell
                    $haskell
                    $haxe
                    $helm
                    $java
                    $julia
                    $kotlin
                    $gradle
                    $lua
                    $nim
                    $nodejs
                    $ocaml
                    $opa
                    $perl
                    $php
                    $pulumi
                    $purescript
                    $python
                    $quarto
                    $raku
                    $rlang
                    $red
                    $ruby
                    $rust
                    $scala
                    $solidity
                    $swift
                    $terraform
                    $typst
                    $vlang
                    $vagrant
                    $zig
                    $buf
                    $nix_shell
                    $conda
                    $meson
                    $spack
                    $memory_usage
                    $aws
                    $gcloud
                    $openstack
                    $azure
                    $nats
                    $direnv
                    $env_var
                    $crystal
                    $custom
                    $sudo
                    $cmd_duration
                    $line_break
                    $jobs
                    $battery
                    $time
                    $status
                    $os
                    $container
                    $shell
                    $username
                    $character
                '';
            };
        };
    };
}
