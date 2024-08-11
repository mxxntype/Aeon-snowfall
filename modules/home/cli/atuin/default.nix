# INFO: Atuin Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.atuin = {
        enable = mkOption {
            description = "Whether to enable Atuin, the magical shell history";
            type = types.bool;
            default = true;
        };

        sync = mkOption {
            description = "Whether to use Atuin's sync feature";
            type = types.bool;
            default = false;
        };

        host = mkOption {
            description = "Whether to host an Atuin server";
            type = types.bool;
            default = false;
        };
    };

    config = mkMerge [
        # Configure an Atuin client.
        (mkIf config.aeon.cli.atuin.enable {
            programs = {
                atuin = {
                    enable = true;
                    flags = [ "--disable-up-arrow" ];
                    settings = {
                        auto_sync = false;
                        update_check = false;
                        search_mode = "fuzzy";
                        filter_mode = "host";
                        secrets_filter = true;
                        style = "compact";
                        inline_height = 24;
                    };

                    enableNushellIntegration = false;
                };

                nushell = {
                    # envFile.text = lib.mkAfter /* nu */ ''
                    #     $env.ATUIN_SESSION = (atuin uuid)
                    #     hide-env -i ATUIN_HISTORY_ID
                    # '';

                    configFile.text = lib.mkAfter /* nu */ ''
                        source ~/.config/nushell/atuin.nu

                        # Magic token to make sure we don"t record commands run by keybindings
                        # let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"

                        # let _atuin_pre_execution = {||
                        #     if ($nu | get -i history-enabled) == false {
                        #         return
                        #     }
                        #     let cmd = (commandline)
                        #     if ($cmd | is-empty) {
                        #         return
                        #     }
                        #     if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
                        #         $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
                        #     }
                        # };

                        # let _atuin_pre_prompt = {||
                        #     let last_exit = $env.LAST_EXIT_CODE;
                        #     if "ATUIN_HISTORY_ID" not-in $env {
                        #         return
                        #     }
                        #     with-env { ATUIN_LOG: error } {
                        #         do { atuin history end $"--exit=($last_exit)" -- $env.ATUIN_HISTORY_ID | null } | null
                        #     }
                        #     hide-env ATUIN_HISTORY_ID
                        # };

                        # def _atuin_search_cmd [...flags: string] {
                        #     let nu_version = ($env.NU_VERSION | split row "." | each { || into int })
                        #     [
                        #         $ATUIN_KEYBINDING_TOKEN,
                        #         # ([
                        #         #     `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`,
                        #         #         (if $nu_version.0 <= 0 and $nu_version.1 <= 90 { 'commandline' } else { 'commandline edit' }),
                        #         #         (if $nu_version.1 >= 92 { '(run-external atuin search' } else { '(run-external --redirect-stderr atuin search' }),
                        #         #             ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                        #         #         (if $nu_version.1 >= 92 { ' e>| str trim)' } else {' | complete | $in.stderr | str substring ..-1)'}),
                        #         #     `}`,
                        #         # ] | flatten | str join ' '),
                        #         #
                        #         # HACK: The code above worked before `--redirect-stderr` got deprecated,
                        #         # the line below is simply the evaluated above expression with `e>|` added
                        #         # to replicate the deprecated functionality. Works now, I think?..
                        #         'commandline edit (ATUIN_LOG=error atuin search "--interactive" "--" (commandline) e>| complete | get stdout | str trim)'
                        #     ] | str join "\n"
                        # }

                        # $env.config = ($env | default {} config).config
                        # $env.config = ($env.config | default {} hooks)
                        # $env.config = ($env.config | upsert hooks ($env.config.hooks
                        #     | upsert pre_execution ($env.config.hooks | get -i pre_execution | default [] | append $_atuin_pre_execution)
                        #     | upsert pre_prompt ($env.config.hooks | get -i pre_prompt | default [] | append $_atuin_pre_prompt)
                        # ))

                        # $env.config = ($env.config | default [] keybindings)

                        # $env.config = ($env.config | upsert keybindings (
                        #     $env.config.keybindings | append {
                        #         name: atuin
                        #         modifier: control
                        #         keycode: char_r
                        #         mode: [emacs, vi_normal, vi_insert]
                        #         event: { send: executehostcommand cmd: (_atuin_search_cmd) }
                        #     }
                        # ))

                        # # INFO: Don't open up the search menu when the up arrow is pressed.
                        # # $env.config = ($env.config | upsert keybindings (
                        # #     $env.config.keybindings | append {
                        # #         name: atuin
                        # #         modifier: none
                        # #         keycode: up
                        # #         mode: [emacs, vi_normal, vi_insert]
                        # #         event: {
                        # #             until: [
                        # #                 {send: menuup}
                        # #                 {send: executehostcommand cmd: (_atuin_search_cmd "--shell-up-key-binding") }
                        # #             ]
                        # #         }
                        # #     }
                        # # ))
                    '';
                };
            };

            home.packages = with pkgs; [ atuin ];

            xdg.configFile."nushell/atuin.nu".text = /* nu */ ''
                $env.ATUIN_SESSION = (atuin uuid)
                hide-env -i ATUIN_HISTORY_ID

                # Magic token to make sure we don't record commands run by keybindings
                let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"

                let _atuin_pre_execution = {||
                    if ($nu | get -i history-enabled) == false {
                        return
                    }
                    let cmd = (commandline)
                    if ($cmd | is-empty) {
                        return
                    }
                    if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
                        $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
                    }
                }

                let _atuin_pre_prompt = {||
                    let last_exit = $env.LAST_EXIT_CODE
                    if 'ATUIN_HISTORY_ID' not-in $env {
                        return
                    }
                    with-env { ATUIN_LOG: error } {
                        do { atuin history end $'--exit=($last_exit)' -- $env.ATUIN_HISTORY_ID } | complete

                    }
                    hide-env ATUIN_HISTORY_ID
                }

                def _atuin_search_cmd [...flags: string] {
                    let nu_version = ($env.NU_VERSION | split row '.' | each { || into int })
                    [
                        $ATUIN_KEYBINDING_TOKEN,
                        ([
                            `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`,
                                (if $nu_version.0 <= 0 and $nu_version.1 <= 90 { 'commandline' } else { 'commandline edit' }),
                                (if $nu_version.1 >= 92 { '(run-external atuin search' } else { '(run-external --redirect-stderr atuin search' }),
                                    ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                                (if $nu_version.1 >= 92 { ' e>| str trim)' } else {' | complete | $in.stderr | str substring ..-1)'}),
                            `}`,
                        ] | flatten | str join ' '),
                    ] | str join "\n"
                }

                $env.config = ($env | default {} config).config
                $env.config = ($env.config | default {} hooks)
                $env.config = (
                    $env.config | upsert hooks (
                        $env.config.hooks
                        | upsert pre_execution (
                            $env.config.hooks | get -i pre_execution | default [] | append $_atuin_pre_execution)
                        | upsert pre_prompt (
                            $env.config.hooks | get -i pre_prompt | default [] | append $_atuin_pre_prompt)
                    )
                )

                $env.config = ($env.config | default [] keybindings)

                $env.config = (
                    $env.config | upsert keybindings (
                        $env.config.keybindings
                        | append {
                            name: atuin
                            modifier: control
                            keycode: char_r
                            mode: [emacs, vi_normal, vi_insert]
                            event: { send: executehostcommand cmd: (_atuin_search_cmd) }
                        }
                    )
                )

                # $env.config = (
                #     $env.config | upsert keybindings (
                #         $env.config.keybindings
                #         | append {
                #             name: atuin
                #             modifier: none
                #             keycode: up
                #             mode: [emacs, vi_normal, vi_insert]
                #             event: {
                #                 until: [
                #                     {send: menuup}
                #                     {send: executehostcommand cmd: (_atuin_search_cmd '--shell-up-key-binding') }
                #                 ]
                #             }
                #         }
                #     )
                # )
            '';
        })    

        # TODO: Configure Atuin's sync feature.
        (mkIf config.aeon.cli.atuin.sync {
            programs.atuin.settings = {
                auto_sync = true;
                sync_frequency = "10m";
                sync_address = "https://api.atuin.sh"; # FIXME
                filter_mode = "global";
                search_mode = "prefix";
            };
        })

        # TODO: Configure an Atuin server.
        (mkIf config.aeon.cli.atuin.host { })    
    ];
}
