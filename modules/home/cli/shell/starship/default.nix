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
                mkSurround = contents: {
                    left ? "[",
                    right ? "]",
                    padLeft ? false,
                    padRight ? false,
                    color ? ui.bg.surface2,
                }:
                    (if padLeft then " " else "") +
                    (if left != null then "[\\${left}](fg:#${color})" else "") +
                    contents +
                    (if right != null then "[\\${right}](fg:#${color})" else "") +
                    (if padRight then " " else "");

                # NOTE: Shortcuts for adding dark-gray square brackets around a block.
                mkContainer = contents: mkSurround contents { padRight = true; };
                mkContainerRight = contents: mkSurround contents { padLeft = false; };
            in {
                add_newline = false;

                username = {
                    style_user = "purple";
                    style_root = "bold red";
                    format = "[$user]($style)[@](fg:#${ui.fg.subtext1})";
                };

                hostname = {
                    ssh_only = false;
                    ssh_symbol = " 󰒋 ";
                    style = "bold blue";
                    format = "[$hostname$ssh_symbol]($style)";
                };

                directory = let
                    baseFormat = "[$path]($style) [$read_only]($read_only_style)";
                in {
                    format = "[ ]($style)${baseFormat}";
                    repo_root_format = "[󰊢 ]($style)[git:](fg:cyan)[$repo_root]($repo_root_style)${baseFormat}";
                    truncation_length = 6;
                    style = "fg:#${ui.fg.subtext1}";
                    before_repo_root_style = "bold fg:#${ui.fg.subtext1}";
                    repo_root_style = "bold white";
                    read_only = "RO";
                    read_only_style = "bold fg:#${colors.yellow}";
                };

                character = let
                    char = ">";
                    style = "bold fg:#${ui.fg.subtext1}";
                in {
                    success_symbol = "[${char}](${style})";
                    error_symbol = "[${char}](${style})";
                };

                git_branch = {
                    format = mkContainer "[$symbol$branch(:$remote_branch)]($style)";
                    symbol = "";
                };

                git_metrics = {
                    format = "([+$added]($added_style))([-$deleted]($deleted_style) )";
                    added_style = "bold fg:#${colors.pink}";
                    deleted_style = "bold fg:#${colors.maroon}";
                    disabled = false;
                };

                git_status = {
                    format = "([$all_status$ahead_behind]($style) )";
                    conflicted = "=";
                    ahead = "";
                    behind = "";
                    diverged = "󰓢";
                    up_to_date = "";
                    untracked = "?";
                    stashed = "";
                    modified = "~";
                    staged = "+";
                    renamed = ">";
                    deleted = "-";
                    typechanged = "";
                    style = "fg:#${colors.rosewater}";
                };

                rust = {
                    format = mkContainer "[$symbol $numver]($style)";
                    symbol = "󱘗";
                    style = "fg:#${colors.peach}";
                };

                package = {
                    format = mkContainer "[$symbol$version]($style)";
                    style = "fg:#${colors.flamingo}";
                };

                status = {
                    disabled = false;
                    format = "[$status]($style) ";
                };

                time = {
                    format = mkContainerRight "[$time]($style)";
                    time_format = "%H:%M %p";
                    style = "fg:#${ui.fg.subtext1}";
                    disabled = false;
                };

                cmd_duration = {
                    format = "[󱎫 $duration]($style) ";
                    style = "fg:#${ui.bg.overlay1}";
                };

                direnv = {
                    format = "([$loaded]($style) )";
                    loaded_msg = "󰦕 ";
                    style = "fg:#${ui.bg.surface2}";
                    disabled = false;
                };

                fill.symbol = " ";

                # PERF: This does not affect the nix3 shell (`nix shell`),
                # however noticeably slows down the whole environment.
                nix_shell.disabled = true;

                aws.disabled = true;

                aws.symbol = "󰸏 ";
                buf.symbol = " ";
                c.symbol = " ";
                conda.symbol = "󰕗 ";
                crystal.symbol = " ";
                dart.symbol = " ";
                docker_context.symbol = "󰡨 ";
                elixir.symbol = " ";
                elm.symbol = " ";
                fennel.symbol = " ";
                fossil_branch.symbol = "󰘬 ";
                golang.symbol = "󰟓 ";
                gradle.symbol = " ";
                guix_shell.symbol = " ";
                haskell.symbol = "󰲒 ";
                haxe.symbol = " ";
                hg_branch.symbol = "󰘬 ";
                java.symbol = "󰬷 ";
                julia.symbol = " ";
                kotlin.symbol = "󱈙 ";
                lua.symbol = "󰢱 ";
                memory_usage.symbol = " ";
                meson.symbol = "󰔷 ";
                nim.symbol = " ";
                nix_shell.symbol = "󱄅 ";
                nodejs.symbol = "󰎙 ";
                ocaml.symbol = " ";
                package.symbol = "󰏗 ";
                perl.symbol = " ";
                php.symbol = "󰌟 ";
                pijul_channel.symbol = "󰘬 ";
                python.symbol = "󰌠 ";
                rlang.symbol = "󰟔 ";
                ruby.symbol = "󰴭 ";
                scala.symbol = " ";
                swift.symbol = "󰛥 ";
                zig.symbol = " ";
                os.symbols = {
                    AlmaLinux = " ";
                    Alpaquita = "󰂚 ";
                    Alpine = " ";
                    Amazon = " ";
                    Android = "󰀲 ";
                    Arch = "󰣇 ";
                    Artix = " ";
                    CentOS = " ";
                    Debian = "󰣚 ";
                    DragonFly = "󱖉 ";
                    Emscripten = " ";
                    EndeavourOS = " ";
                    Fedora = "󰣛 ";
                    FreeBSD = "󰣠 ";
                    Garuda = " ";
                    Gentoo = "󰣨 ";
                    HardenedBSD = "󰞌 ";
                    Illumos = " ";
                    Kali = " ";
                    Linux = "󰌽 ";
                    Mabox = "󰏗 ";
                    Macos = "󰀵 ";
                    Manjaro = "󱘊 ";
                    Mariner = "󰒸 ";
                    MidnightBSD = "󰽥 ";
                    Mint = "󰣭 ";
                    NetBSD = "󰈻 ";
                    NixOS = "󱄅 ";
                    OpenBSD = " ";
                    OracleLinux = "󰌷 ";
                    Pop = " ";
                    Raspbian = " ";
                    RedHatEnterprise = "󰮤 ";
                    Redhat = "󰮤 ";
                    Redox = "󰹻 ";
                    RockyLinux = " ";
                    SUSE = " ";
                    Solus = " ";
                    Ubuntu = " ";
                    Unknown = "󰌽 ";
                    Void = " ";
                    Windows = "󰖳 ";
                };

                format = builtins.replaceStrings [ "\n" ] [ "" ] ''
                    [\[](fg:#${ui.bg.surface2})
                    $username
                    $hostname
                    [\] ](fg:#${ui.bg.surface2})

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
                    $package
                    $custom
                    $sudo

                    $fill

                    $status
                    $cmd_duration
                    $git_status
                    $git_metrics
                    $time

                    $line_break

                    $jobs
                    $battery
                    $os
                    $container
                    $shell
                    $character
                '';
            };
        };
    };
}
