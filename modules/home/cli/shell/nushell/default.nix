# INFO: Nushell Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.cli.shell.nushell = {
        enable = mkOption {
            description = "Whether to enable Nushell, a new type of shell";
            type = types.bool;
            default = true;
        };
    };
    
    config = let
        inherit (config.aeon.theme)
            ui
            ;
    in mkIf config.aeon.cli.shell.nushell.enable {
        programs = {
            nushell = {
                enable = true;
                package = pkgs.nushell;

                # HACK: Nushell doesn't pick up some environment variables sometimes.
                #
                # This takes general Home-manager variables and makes them Nushell's too.
                environmentVariables = let
                    escapedVariables = { }
                        |> lib.recursiveUpdate config.home.sessionVariables
                        |> builtins.mapAttrs (_: value: "\"${toString value}\"");
                    badVariables = [
                        # HACK: This one is set to something hella fucking weird, and having it
                        # present seems to break the cursor in some apps, like the Zen browser.
                        "XCURSOR_PATH"
                    ];
                in builtins.removeAttrs escapedVariables badVariables;
                
                shellAliases = {
                    lsa = "ls -a";
                    cat = "${pkgs.bat}/bin/bat";
                    btm = "${pkgs.bottom}/bin/btm --battery";
                    ip = "ip --color=always";
                    duf = "${pkgs.duf}/bin/duf -theme ansi";
                    # tree = "erd --config tree";
                    # sz = "erd --config sz";
                };

                configFile.text = /* nu */ ''
                    # Nushell Config File.
                    #
                    # version = "0.94.1"

                    # For more information on themes see https://www.nushell.sh/book/coloring_and_theming.html
                    # And here is the theme collection:  https://github.com/nushell/nu_scripts/tree/main/themes
                    let dark_theme = {
                        separator: dark_gray
                        header: white_bold
                        row_index: white_bold

                        empty: blue
                        leading_trailing_space_bg: { attr: n }

                        filesize: cyan
                        duration: white
                        date: purple

                        bool: light_cyan
                        int: white
                        float: white
                        range: white
                        string: green
                        nothing: white
                        binary: white
                        cell-path: white
                        record: white
                        list: white
                        block: white

                        hints: dark_gray
                        search_result: { bg: red fg: white }

                        # Shapes are used to change the CLI syntax highlighting.
                        shape_and: purple_bold
                        shape_binary: purple_bold
                        shape_block: blue_bold
                        shape_bool: light_cyan
                        shape_closure: green_bold
                        shape_custom: green
                        shape_datetime: cyan_bold
                        shape_directory: cyan
                        shape_external: cyan
                        shape_externalarg: green_bold
                        shape_external_resolved: light_yellow_bold
                        shape_filepath: cyan
                        shape_flag: blue_bold
                        shape_float: purple_bold
                        shape_garbage: { fg: white bg: red attr: b}
                        shape_globpattern: cyan_bold
                        shape_int: purple_bold
                        shape_internalcall: cyan_bold
                        shape_keyword: cyan_bold
                        shape_list: cyan_bold
                        shape_literal: blue
                        shape_match_pattern: green
                        shape_matching_brackets: { attr: u }
                        shape_nothing: light_cyan
                        shape_operator: yellow
                        shape_or: purple_bold
                        shape_pipe: purple_bold
                        shape_range: yellow_bold
                        shape_record: cyan_bold
                        shape_redirection: purple_bold
                        shape_signature: green_bold
                        shape_string: green
                        shape_string_interpolation: cyan_bold
                        shape_table: blue_bold
                        shape_variable: purple
                        shape_vardecl: purple
                        shape_raw_string: light_purple
                    }

                    # TODO:
                    let carapace_completer = {|spans|
                        ${pkgs.carapace}/bin/carapace $spans.0 nushell ...$spans | from json
                    }

                    # The default config record. This is where much of your global configuration is setup.
                    $env.config = {
                        show_banner: false

                        ls: {
                            use_ls_colors: true
                            clickable_links: true
                        }

                        rm: {
                            always_trash: false
                        }

                        table: {
                            mode: rounded                  # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
                            index_mode: always             # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
                            show_empty: true               # show 'empty list' and 'empty record' placeholders for command output
                            padding: { left: 1, right: 1 } # a left right padding of each column in a table
                            trim: {
                                methodology: truncating       # wrapping or truncating
                                wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
                                truncating_suffix: "..."      # A suffix used by the 'truncating' methodology
                            }
                            header_on_separator: false  # show header text on separator/border line
                            # abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set point
                        }

                        error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages

                        # Whether an error message should be printed if an error of a certain kind is triggered.
                        display_errors: {
                            # Assume the external command prints an error message.
                            exit_code: false
                            # Core dump errors are always printed, and SIGPIPE never triggers an error.
                            # The setting below controls message printing for termination by all other signals.
                            termination_signal: true
                        }

                        # datetime_format determines what a datetime rendered in the shell would look like.
                        # Behavior without this configuration point will be to "humanize" the datetime display,
                        # showing something like "a day ago."
                        datetime_format: {
                            # normal: '%a, %d %b %Y %H:%M:%S %z'    # shows up in displays of variables or other datetime's outside of tables
                            # table: '%m/%d/%y %I:%M:%S%p'          # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
                        }

                        explore: {
                            status_bar_background: { fg: "#${ui.fg.text}", bg: "#${ui.bg.surface0}" },
                            command_bar_text: { fg: "#${ui.fg.text}" },
                            highlight: { fg: "black", bg: "yellow" },
                            status: {
                                error: { fg: "white", bg: "red" },
                                warn: {}
                                info: {}
                            },
                            table: {
                                split_line: { fg: dark_gray },
                                selected_cell: { bg: light_blue },
                                selected_row: {},
                                selected_column: {},
                            },
                        }

                        history: {
                            max_size: 100_000        # Session has to be reloaded for this to take effect.
                            sync_on_enter: true      # Enable to share history between multiple sessions, else you have to close the session to write history to file.
                            file_format: "plaintext" # "sqlite" or "plaintext".

                            # NOTE: Only available with sqlite file_format.
                            # `true` enables history isolation, `false` disables it.
                            # `true` will allow the history to be isolated to the current session using up/down arrows.
                            # `false` will allow the history to be shared across all sessions.
                            isolation: false
                        }

                        completions: {
                            case_sensitive: false # Set to true to enable case-sensitive completions.
                            quick: true           # Set this to false to prevent auto-selecting completions when only one remains.
                            partial: true         # Set this to false to prevent partial filling of the prompt.
                            algorithm: "prefix"   # `prefix` or `fuzzy`.
                            use_ls_colors: true   # set this to true to enable file/path/directory completions using `$env.LS_COLORS`.
                            external: {
                                # Set to `false` to prevent nushell looking into $env.PATH to find more suggestions.
                                # `false` recommended for WSL users as this look up may be very slow.
                                enable: true     
                                max_results: 100 # Setting it lower can improve completion performance at the cost of omitting some options.
                                completer: $carapace_completer
                            }
                        }

                        filesize: {
                            metric: false # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
                            format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
                        }

                        cursor_shape: {
                            emacs: line           # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
                            vi_insert: block      # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
                            vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
                        }

                        color_config: $dark_theme # You can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
                        footer_mode: "25"         # `always`, `never`, `number_of_rows`, `auto`
                        float_precision: 2        # The precision for displaying floats in tables.
                        buffer_editor: ""         # Command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL.
                        use_ansi_coloring: true
                        bracketed_paste: true     # Enable bracketed paste, currently useless on Windows.
                        edit_mode: emacs          # `emacs`/  `vi`

                        shell_integration: {
                            # `osc2` abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title.
                            osc2: true

                            # `osc7` is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory.
                            osc7: true

                            # `osc8` is also implemented as the deprecated setting ls.show_clickable_links
                            # It shows clickable links in ls output if your terminal supports it.
                            # NOTE: show_clickable_links is deprecated in favor of `osc8`
                            osc8: true

                            # `osc9_9` is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal.
                            osc9_9: false

                            # `osc133` is several escapes invented by Final Term which include the supported ones below.
                            # 133;A - Mark prompt start
                            # 133;B - Mark prompt end
                            # 133;C - Mark pre-execution
                            # 133;D;exit - Mark execution finished with exit code
                            # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is.
                            osc133: true

                            # `osc633` is closely related to `osc133` but only exists in visual studio code (vscode) and supports their shell integration features.
                            # 633;A - Mark prompt start
                            # 633;B - Mark prompt end
                            # 633;C - Mark pre-execution
                            # 633;D;exit - Mark execution finished with exit code
                            # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
                            # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
                            # and also helps with the run recent menu in vscode.
                            osc633: true

                            # reset_application_mode is escape \x1b[?1l and was added to help ssh work better.
                            reset_application_mode: true
                        }

                        render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
                        use_kitty_protocol: false # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
                        highlight_resolved_externals: false # true enables highlighting of external commands in the repl resolved by which.
                        recursion_limit: 50 # the maximum number of times nushell allows recursion before stopping it

                        plugins: {} # Per-plugin configuration. See https://www.nushell.sh/contributor-book/plugins.html#configuration.

                        plugin_gc: {
                            # Configuration for plugin garbage collection
                            default: {
                                enabled: true # true to enable stopping of inactive plugins
                                stop_after: 10sec # how long to wait after a plugin is inactive to stop it
                            }

                            plugins: {
                                # alternate configuration for specific plugins, by name, for example:
                                #
                                # gstat: {
                                #     enabled: false
                                # }
                            }
                        }

                        hooks: {
                            pre_prompt: [{ null }] # run before the prompt is shown
                            pre_execution: [{ null }] # run before the repl input is run
                            env_change: {
                                PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
                            }
                            display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline
                            command_not_found: { null } # return an error message when a command is not found
                        }

                        menus: [
                            # Configuration for default nushell menus.
                            # Note the lack of source parameter.
                            {
                                name: completion_menu
                                only_buffer_difference: false
                                marker: "| "
                                type: {
                                    layout: columnar
                                    columns: 4
                                    col_width: 20     # Optional value. If missing all the screen width is used to calculate column width.
                                    col_padding: 2
                                }
                                style: {
                                    text: green
                                    selected_text: { attr: r }
                                    description_text: yellow
                                    match_text: { attr: u }
                                    selected_match_text: { attr: ur }
                                }
                            }
                            {
                                name: ide_completion_menu
                                only_buffer_difference: false
                                marker: "| "
                                type: {
                                    layout: ide
                                    min_completion_width: 0,
                                    max_completion_width: 50,
                                    max_completion_height: 10, # Will be limited by the available lines in the terminal.
                                    padding: 0,
                                    border: true,
                                    cursor_offset: 0,
                                    description_mode: "prefer_right"
                                    min_description_width: 0
                                    max_description_width: 50
                                    max_description_height: 10
                                    description_offset: 1

                                    # If true, the cursor pos will be corrected, so the suggestions match up with the typed text
                                    #
                                    # C:\> str
                                    #      str join
                                    #      str trim
                                    #      str split
                                    correct_cursor_pos: true
                                }
                                style: {
                                    text: green
                                    selected_text: { attr: r }
                                    description_text: yellow
                                    match_text: { attr: u }
                                    selected_match_text: { attr: ur }
                                }
                            }
                            {
                                name: history_menu
                                only_buffer_difference: true
                                marker: "? "
                                type: {
                                    layout: list
                                    page_size: 10
                                }
                                style: {
                                    text: green
                                    selected_text: green_reverse
                                    description_text: yellow
                                }
                            }
                            {
                                name: help_menu
                                only_buffer_difference: true
                                marker: "? "
                                type: {
                                    layout: description
                                    columns: 4
                                    col_width: 20     # Optional value. If missing all the screen width is used to calculate column width
                                    col_padding: 2
                                    selection_rows: 4
                                    description_rows: 10
                                }
                                style: {
                                    text: green
                                    selected_text: green_reverse
                                    description_text: yellow
                                }
                            }
                        ]

                        keybindings: [
                            {
                                name: completion_menu
                                modifier: none
                                keycode: tab
                                mode: [emacs vi_normal vi_insert]
                                event: {
                                    until: [
                                        { send: menu name: completion_menu }
                                        { send: menunext }
                                        { edit: complete }
                                    ]
                                }
                            }
                            {
                                name: ide_completion_menu
                                modifier: control
                                keycode: char_n
                                mode: [emacs vi_normal vi_insert]
                                event: {
                                    until: [
                                        { send: menu name: ide_completion_menu }
                                        { send: menunext }
                                        { edit: complete }
                                    ]
                                }
                            }
                            {
                                name: history_menu
                                modifier: control
                                keycode: char_r
                                mode: [emacs, vi_insert, vi_normal]
                                event: { send: menu name: history_menu }
                            }
                            {
                                name: help_menu
                                modifier: none
                                keycode: f1
                                mode: [emacs, vi_insert, vi_normal]
                                event: { send: menu name: help_menu }
                            }
                            {
                                name: completion_previous_menu
                                modifier: shift
                                keycode: backtab
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: menuprevious }
                            }
                            {
                                name: next_page_menu
                                modifier: control
                                keycode: char_x
                                mode: emacs
                                event: { send: menupagenext }
                            }
                            {
                                name: undo_or_previous_page_menu
                                modifier: control
                                keycode: char_z
                                mode: emacs
                                event: {
                                    until: [
                                        { send: menupageprevious }
                                        { edit: undo }
                                    ]
                                }
                            }
                            {
                                name: escape
                                modifier: none
                                keycode: escape
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: esc }    # NOTE: does not appear to work
                            }
                            {
                                name: cancel_command
                                modifier: control
                                keycode: char_c
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: ctrlc }
                            }
                            {
                                name: quit_shell
                                modifier: control
                                keycode: char_d
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: ctrld }
                            }
                            {
                                name: clear_screen
                                modifier: control
                                keycode: char_l
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: clearscreen }
                            }
                            {
                                name: search_history
                                modifier: control
                                keycode: char_q
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: searchhistory }
                            }
                            {
                                name: open_command_editor
                                modifier: control
                                keycode: char_o
                                mode: [emacs, vi_normal, vi_insert]
                                event: { send: openeditor }
                            }
                            {
                                name: move_up
                                modifier: none
                                keycode: up
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: menuup }
                                        { send: up }
                                    ]
                                }
                            }
                            {
                                name: move_down
                                modifier: none
                                keycode: down
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: menudown }
                                        { send: down }
                                    ]
                                }
                            }
                            {
                                name: move_left
                                modifier: none
                                keycode: left
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: menuleft }
                                        { send: left }
                                    ]
                                }
                            }
                            {
                                name: move_right_or_take_history_hint
                                modifier: none
                                keycode: right
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: historyhintcomplete }
                                        { send: menuright }
                                        { send: right }
                                    ]
                                }
                            }
                            {
                                name: move_one_word_left
                                modifier: control
                                keycode: left
                                mode: [emacs, vi_normal, vi_insert]
                                event: { edit: movewordleft }
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: control
                                keycode: right
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: historyhintwordcomplete }
                                        { edit: movewordright }
                                    ]
                                }
                            }
                            {
                                name: move_to_line_start
                                modifier: none
                                keycode: home
                                mode: [emacs, vi_normal, vi_insert]
                                event: { edit: movetolinestart }
                            }
                            {
                                name: move_to_line_start
                                modifier: control
                                keycode: char_a
                                mode: [emacs, vi_normal, vi_insert]
                                event: { edit: movetolinestart }
                            }
                            {
                                name: move_to_line_end_or_take_history_hint
                                modifier: none
                                keycode: end
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: historyhintcomplete }
                                        { edit: movetolineend }
                                    ]
                                }
                            }
                            {
                                name: move_to_line_end_or_take_history_hint
                                modifier: control
                                keycode: char_e
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: historyhintcomplete }
                                        { edit: movetolineend }
                                    ]
                                }
                            }
                            {
                                name: move_to_line_start
                                modifier: control
                                keycode: home
                                mode: [emacs, vi_normal, vi_insert]
                                event: { edit: movetolinestart }
                            }
                            {
                                name: move_to_line_end
                                modifier: control
                                keycode: end
                                mode: [emacs, vi_normal, vi_insert]
                                event: { edit: movetolineend }
                            }
                            {
                                name: move_up
                                modifier: control
                                keycode: char_p
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: menuup }
                                        { send: up }
                                    ]
                                }
                            }
                            {
                                name: move_down
                                modifier: control
                                keycode: char_t
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        { send: menudown }
                                        { send: down }
                                    ]
                                }
                            }
                            {
                                name: delete_one_character_backward
                                modifier: none
                                keycode: backspace
                                mode: [emacs, vi_insert]
                                event: { edit: backspace }
                            }
                            {
                                name: delete_one_word_backward
                                modifier: control
                                keycode: backspace
                                mode: [emacs, vi_insert]
                                event: { edit: backspaceword }
                            }
                            {
                                name: delete_one_character_forward
                                modifier: none
                                keycode: delete
                                mode: [emacs, vi_insert]
                                event: { edit: delete }
                            }
                            {
                                name: delete_one_character_forward
                                modifier: control
                                keycode: delete
                                mode: [emacs, vi_insert]
                                event: { edit: delete }
                            }
                            {
                                name: delete_one_character_backward
                                modifier: control
                                keycode: char_h
                                mode: [emacs, vi_insert]
                                event: { edit: backspace }
                            }
                            {
                                name: delete_one_word_backward
                                modifier: control
                                keycode: char_w
                                mode: [emacs, vi_insert]
                                event: { edit: backspaceword }
                            }
                            {
                                name: move_left
                                modifier: none
                                keycode: backspace
                                mode: vi_normal
                                event: { edit: moveleft }
                            }
                            {
                                name: newline_or_run_command
                                modifier: none
                                keycode: enter
                                mode: emacs
                                event: { send: enter }
                            }
                            {
                                name: move_left
                                modifier: control
                                keycode: char_b
                                mode: emacs
                                event: {
                                    until: [
                                        { send: menuleft }
                                        { send: left }
                                    ]
                                }
                            }
                            {
                                name: move_right_or_take_history_hint
                                modifier: control
                                keycode: char_f
                                mode: emacs
                                event: {
                                    until: [
                                        { send: historyhintcomplete }
                                        { send: menuright }
                                        { send: right }
                                    ]
                                }
                            }
                            {
                                name: redo_change
                                modifier: control
                                keycode: char_g
                                mode: emacs
                                event: { edit: redo }
                            }
                            {
                                name: undo_change
                                modifier: control
                                keycode: char_z
                                mode: emacs
                                event: { edit: undo }
                            }
                            {
                                name: paste_before
                                modifier: control
                                keycode: char_y
                                mode: emacs
                                event: { edit: pastecutbufferbefore }
                            }
                            {
                                name: cut_word_left
                                modifier: control
                                keycode: char_w
                                mode: emacs
                                event: { edit: cutwordleft }
                            }
                            {
                                name: cut_line_to_end
                                modifier: control
                                keycode: char_k
                                mode: emacs
                                event: { edit: cuttoend }
                            }
                            {
                                name: cut_line_from_start
                                modifier: control
                                keycode: char_u
                                mode: emacs
                                event: { edit: cutfromstart }
                            }
                            {
                                name: swap_graphemes
                                modifier: control
                                keycode: char_t
                                mode: emacs
                                event: { edit: swapgraphemes }
                            }
                            {
                                name: move_one_word_left
                                modifier: alt
                                keycode: left
                                mode: emacs
                                event: { edit: movewordleft }
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: alt
                                keycode: right
                                mode: emacs
                                event: {
                                    until: [
                                        { send: historyhintwordcomplete }
                                        { edit: movewordright }
                                    ]
                                }
                            }
                            {
                                name: move_one_word_left
                                modifier: alt
                                keycode: char_b
                                mode: emacs
                                event: { edit: movewordleft }
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: alt
                                keycode: char_f
                                mode: emacs
                                event: {
                                    until: [
                                        { send: historyhintwordcomplete }
                                        { edit: movewordright }
                                    ]
                                }
                            }
                            {
                                name: delete_one_word_forward
                                modifier: alt
                                keycode: delete
                                mode: emacs
                                event: { edit: deleteword }
                            }
                            {
                                name: delete_one_word_backward
                                modifier: alt
                                keycode: backspace
                                mode: emacs
                                event: { edit: backspaceword }
                            }
                            {
                                name: delete_one_word_backward
                                modifier: alt
                                keycode: char_m
                                mode: emacs
                                event: { edit: backspaceword }
                            }
                            {
                                name: cut_word_to_right
                                modifier: alt
                                keycode: char_d
                                mode: emacs
                                event: { edit: cutwordright }
                            }
                            {
                                name: upper_case_word
                                modifier: alt
                                keycode: char_u
                                mode: emacs
                                event: { edit: uppercaseword }
                            }
                            {
                                name: lower_case_word
                                modifier: alt
                                keycode: char_l
                                mode: emacs
                                event: { edit: lowercaseword }
                            }
                            {
                                name: capitalize_char
                                modifier: alt
                                keycode: char_c
                                mode: emacs
                                event: { edit: capitalizechar }
                            }

                            # NOTE: The following bindings with `*system` events require that
                            # Nushell has been compiled with the `system-clipboard` feature.
                            #
                            # This should be the case for Windows, macOS, and most Linux distributions.
                            # Not available for example on Android (termux).
                            # If you want to use the system clipboard for visual selection or to
                            # paste directly, uncomment the respective lines and replace the version
                            # using the internal clipboard.
                            {
                                name: copy_selection
                                modifier: control_shift
                                keycode: char_c
                                mode: emacs
                                event: { edit: copyselection }
                                # event: { edit: copyselectionsystem }
                            }
                            {
                                name: cut_selection
                                modifier: control_shift
                                keycode: char_x
                                mode: emacs
                                event: { edit: cutselection }
                                # event: { edit: cutselectionsystem }
                            }
                            # {
                            #     name: paste_system
                            #     modifier: control_shift
                            #     keycode: char_v
                            #     mode: emacs
                            #     event: { edit: pastesystem }
                            # }
                            {
                                name: select_all
                                modifier: control_shift
                                keycode: char_a
                                mode: emacs
                                event: { edit: selectall }
                            }
                        ]
                    }
                '';

                envFile.text = /* nu */ ''
                    # Nushell Environment Config File
                    #
                    # version = "0.94.1"

                    def create_left_prompt [] {
                        let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
                            null => $env.PWD
                            "" => '~'
                            $relative_pwd => ([~ $relative_pwd] | path join)
                        }

                        let path_color = (if (is-admin) { ansi red_bold } else { ansi magenta_bold })
                        let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_magenta_bold })
                        let path_segment = $"($path_color)($dir | path split | last 3 | path join)"
                        let current_dir = $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"

                        $"(ansi blue_bold)(hostname | str downcase)(ansi reset) ($current_dir)"
                    }

                    def create_right_prompt [] {
                        # Create a right prompt in magenta with green separators and am/pm underlined.
                        let time_segment = ([
                            (ansi reset)
                            (ansi magenta)
                            (date now | format date '%x %X') # try to respect user's locale.
                        ] | str join | str replace --regex --all "([/:])" $"(ansi green)''${1}(ansi magenta)" |
                            str replace --regex --all "([AP]M)" $"(ansi magenta_underline)''${1}")

                        let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
                            (ansi rb)
                            ($env.LAST_EXIT_CODE)
                        ] | str join)
                        } else { "" }

                        ([$last_exit_code, (char space), $time_segment] | str join)
                    }

                    # Use nushell functions to define your right and left prompt.
                    $env.PROMPT_COMMAND = {|| create_left_prompt }
                    $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
                    $env.PROMPT_INDICATOR = {|| " ~> " }
                    $env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
                    $env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
                    $env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

                    # If you want previously entered commands to have a different prompt from the usual one,
                    # you can uncomment one or more of the following lines.
                    #
                    # This can be useful if you have a 2-line prompt and it's taking up a lot of space
                    # because every command entered takes up 2 lines instead of 1. You can then uncomment
                    # the line below so that previously entered commands show with a single `🚀`.
                    # $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
                    # $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
                    # $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
                    # $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
                    # $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
                    # $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

                    # Specifies how environment variables are:
                    # - converted from a string to a value on Nushell startup (from_string)
                    # - converted from a value back to a string when running external commands (to_string)
                    # Note: The conversions happen *after* config.nu is loaded.
                    $env.ENV_CONVERSIONS = {
                        "PATH": {
                            from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
                            to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
                        }
                        "Path": {
                            from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
                            to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
                        }
                    }

                    # Directories to search for scripts when calling source or use.
                    # The default for this is `$nu.default-config-dir/scripts`
                    $env.NU_LIB_DIRS = [
                        ($nu.default-config-dir | path join 'scripts') # Add `<nushell-config-dir>/scripts`
                    ]

                    # Directories to search for plugin binaries when calling register.
                    # The default for this is `$nu.default-config-dir/plugins`
                    $env.NU_PLUGIN_DIRS = [
                        ($nu.default-config-dir | path join 'plugins') # Add `<nushell-config-dir>/plugins`
                    ]

                    # To add entries to PATH (on Windows you might use Path), you can use the following pattern:
                    $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

                    # An alternate way to add entries to $env.PATH is the custom
                    # command `path add` which is built into the nushell stdlib:
                    #
                    # use std "path add"
                    # $env.PATH = ($env.PATH | split row (char esep))
                    #
                    # path add /some/path
                    # path add ($env.CARGO_HOME | path join "bin")
                    # path add ($env.HOME | path join ".local" "bin")
                    # $env.PATH = ($env.PATH | uniq)

                    # To load from a custom file you can use:
                    # source ($nu.default-config-dir | path join 'custom.nu')
                    
                    # Use the colormap from the current theme.
                    $env.LS_COLORS = "${config.aeon.theme.cli.ls}"

                    # Autostart an SSH agent and don't start more than one of it.
                    #
                    # WARNING: This might be kinda insecure. IDK :)
                    let ssh_agent_env_path = $"/tmp/ssh-agent-($env.USER).nuon"
                    if ($ssh_agent_env_path | path exists) and ($"/proc/(open $ssh_agent_env_path | get SSH_AGENT_PID)" | path exists) {
                        load-env (open $ssh_agent_env_path)
                    } else {
                        ^ssh-agent -c
                            | lines
                            | first 2
                            | parse "setenv {name} {value};"
                            | transpose -r
                            | into record
                            | save --force $ssh_agent_env_path
                        load-env (open $ssh_agent_env_path)
                    }

                    # If no keys are added, prompt to add one ASAP.
                    let added_keys_count = ssh-add -l | lines | enumerate | where item =~ SHA | length
                    if $added_keys_count == 0 {
                        ssh-add
                    }
                '';
            };

            # TODO: Multi-shell multi-command argument completer.
            # carapace.enable = true;
        };
    };
}
