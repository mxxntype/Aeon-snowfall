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
                mkContainerRight = contents: "[\\[](fg:#${ui.bg.surface2})${contents}[\\]](fg:#${ui.bg.surface2})";
            in {
                add_newline = false;

                username = {
                    style_user = "bold purple";
                    style_root = "bold red";
                    format = "[$user]($style) ";
                };

                hostname = {
                    ssh_only = true;
                    ssh_symbol = "󰑔 ";
                    style = "bold blue";
                    format = "[$ssh_symbol]($style)${mkContainer "[$hostname]($style)"}";
                };

                directory = {
                    format = "[󰉋 $path]($style)[$read_only]($read_only_style) ";
                    truncation_length = 6;
                    style = "fg:#${ui.fg.subtext1}";
                    repo_root_style = "bold white";
                    read_only = "RO";
                    read_only_style = "bold fg:#${colors.yellow}";
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
                    format = mkContainerRight "[󰅐 $time]($style)";
                    time_format = "%H:%M %p";
                    style = "fg:#${ui.fg.subtext1}";
                    disabled = false;
                };

                cmd_duration = {
                    format = "[󰓅 $duration]($style) ";
                    style = "fg:#${ui.bg.overlay1}";
                };

                fill = {
                    symbol = " ";
                };

                # PERF: This does not affect the nix3 shell (`nix shell`),
                # however noticeably slows down the whole environment.
                nix_shell.disabled = true;

                git_status.disabled = true;

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
                    $package
                    $custom
                    $sudo
                    $fill
                    $status
                    $cmd_duration
                    $time
                    $line_break
                    $jobs
                    $battery
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
