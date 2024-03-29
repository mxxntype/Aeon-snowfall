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
        inherit (config.aeon.theme) colors cli ui code;
    in mkIf config.aeon.cli.shell.nushell.enable {
        programs = {
            nushell = {
                enable = true;
                package = pkgs.nushellFull;

                # HACK: Nushell doesn't pick up some envvars sometimes.
                #
                # This takes general Home-manager variables and makes them Nushell's too.
                environmentVariables = recursiveUpdate config.home.sessionVariables {};
                
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
                    let dark_theme = {
                        # Colors for nushell primitives.
                        separator: "#${ui.bg.surface1}"
                        leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off.
                        header: white_bold
                        empty: blue
                        # Closures can be used to choose colors for specific values.
                        # The value (in this case, a bool) is piped into the closure.
                        # eg) {|| if $in { 'light_cyan' } else { 'light_gray' } }
                        bool: "#${code.boolean}"
                        int: "#${code.number}"
                        filesize: cyan
                        duration: white
                        date: purple
                        range: "#${code.range}"
                        float: "#${code.number}"
                        string: "#${code.string}"
                        nothing: white
                        binary: white
                        cell-path: white
                        row_index: white_bold
                        record: white
                        list: white
                        block: white
                        hints: dark_gray
                        search_result: {bg: "#${ui.accent}", fg: black}
                        # Shapes are used to change the cli syntax highlighting.
                        shape_and: "#${code.operator.logic}"
                        shape_binary: "#${code.operator.logic}"
                        shape_block: blue_bold
                        shape_bool: "#${code.boolean}"
                        shape_closure: "#${code.function}"
                        shape_custom: green
                        shape_datetime: cyan_bold
                        shape_directory: cyan_italic
                        shape_external: "#${cli.external}"
                        shape_externalarg: "#${cli.argument}"
                        shape_filepath: "#${code.path}"
                        shape_flag: "#${cli.argument}"
                        shape_float: "#${code.number}"
                        shape_garbage: { fg: "#${ui.error}" attr: b}
                        shape_globpattern: cyan_bold
                        shape_int: "#${code.number}"
                        shape_internalcall: "#${cli.builtin}"
                        shape_list: cyan_bold
                        shape_literal: blue
                        shape_match_pattern: "#${code.pattern}"
                        shape_matching_brackets: { attr: u }
                        shape_nothing: light_cyan
                        shape_operator: "#${code.operator.math}"
                        shape_or: "#${code.operator.logic}"
                        shape_pipe: "#${code.punctuation}"
                        shape_range: "#${code.range}"
                        shape_record: cyan_bold
                        shape_redirection: purple_bold
                        shape_signature: "#${code.type}"
                        shape_string: "#${code.string}"
                        shape_string_interpolation: {fg: "#${code.string}", attr: b}
                        shape_table: blue_bold
                        shape_variable: "#${code.variable}"
                        shape_vardecl: "#${code.keyword}"
                    }

                    # External completer.
                    # let carapace_completer = {|spans|
                    #     carapace $spans.0 nushell $spans | from json.
                    # }

                    # The default config record. This is where much of your global configuration is setup.
                    $env.config = {
                        show_banner: false # True or false to enable or disable the welcome banner at startup.

                        ls: {
                            use_ls_colors: true # Use the LS_COLORS environment variable to colorize output.
                            clickable_links: true # Enable or disable clickable links. Your terminal has to support links.
                        }

                        rm: {
                            always_trash: true # Always act as if -t was given. Can be overridden with -p.
                        }

                        table: {
                            mode: rounded # Basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other.
                            index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column.
                            show_empty: true # show 'empty list' and 'empty record' placeholders for command output.
                            padding: { left: 1, right: 1 } # a left right padding of each column in a table.
                            trim: {
                                methodology: truncating # Wrapping or truncating.
                                wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology.
                                truncating_suffix: "..." # A suffix used by the 'truncating' methodology.
                            }
                            header_on_separator: false # Show header text on separator/border line.
                            # abbreviated_row_count: 10 # Limit data rows from top and bottom after reaching a set point.
                        }

                        error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages.

                        # Datetime_format determines what a datetime rendered in the shell would look like.
                        # Behavior without this configuration point will be to "humanize" the datetime display,
                        # Showing something like "a day ago."
                        datetime_format: {
                            # normal: '%a, %d %b %Y %H:%M:%S %z'    # Shows up in displays of variables or other datetime's outside of tables.
                            # table: '%m/%d/%y %I:%M:%S%p'          # Generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format.
                        }

                        explore: {
                            status_bar_background: {fg: "${ui.fg.text}", bg: "#${ui.bg.surface0}"},
                            command_bar_text: {fg: "#${colors.teal}"},
                            highlight: {fg: "#${ui.bg.base}", bg: "#${ui.accent}"},
                            status: {
                                error: {fg: "#${ui.bg.base}", bg: "#${ui.error}"},
                                warn: {fg: "#${ui.bg.base}", bg: "#${ui.warn}"},
                                info: {fg: "#${ui.bg.base}", bg: "#${ui.info}"},
                            },
                            table: {
                                split_line: {fg: "#${ui.bg.surface1}"},
                                selected_cell: {bg: "#${ui.bg.surface1}"},
                                selected_row: {bg: "#${ui.bg.surface1}"},
                                selected_column: {bg: "#${ui.bg.surface1}"},
                            },
                        }

                        # NOTE: Shadowed by Atuin.
                        history: {
                            max_size: 100000 # Session has to be reloaded for this to take effect.
                            sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file.
                            file_format: "plaintext" # "sqlite" or "plaintext"
                            isolation: false # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
                        }

                        completions: {
                            case_sensitive: false # set to true to enable case-sensitive completions.
                            quick: true    # set this to false to prevent auto-selecting completions when only one remains.
                            partial: true    # set this to false to prevent partial filling of the prompt.
                            algorithm: "prefix"    # prefix or fuzzy.
                            # external: {
                            #     enable: false # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow.
                            #     max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options.
                            #     completer: $carapace_completer # check 'carapace_completer' above as an example.
                            # }
                        }

                        filesize: {
                            metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
                            format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto.
                        }

                        cursor_shape: {
                            emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
                            vi_insert: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
                            vi_normal: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
                        }

                        color_config: $dark_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record.
                        use_grid_icons: true
                        footer_mode: "25" # always, never, number_of_rows, auto.
                        float_precision: 2 # the precision for displaying floats in tables.
                        buffer_editor: "hx" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL.
                        use_ansi_coloring: true
                        bracketed_paste: true # enable bracketed paste, currently useless on windows.
                        edit_mode: emacs # emacs, vi.
                        shell_integration: false # enables terminal shell integration. Off by default, as some terminals have issues with this.
                        render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
                        use_kitty_protocol: true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.

                        hooks: {
                            pre_prompt: [{ null }] # run before the prompt is shown.
                            pre_execution: [{ null }] # run before the repl input is run.
                            env_change: {
                                PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input.
                            }
                            display_output: "if (term size).columns >= 100 { table -e } else { table }" # run to display the output of a pipeline.
                            command_not_found: { null } # return an error message when a command is not found.
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
                                    col_width: 20 # If missing all the screen width is used to calculate column width.
                                    col_padding: 2
                                }
                                style: {
                                    text: "#${colors.teal}"
                                    selected_text: {fg: "#${ui.bg.base}", bg: "#${colors.teal}", attr: "b"}
                                    description_text: {fg: "#${ui.fg.text}", attr: "i"}
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
                                    text: "#${colors.teal}"
                                    selected_text: {fg: "#${ui.bg.base}", bg: "#${colors.teal}", attr: "b"}
                                    description_text: {fg: "#${ui.fg.text}", attr: "i"}
                                }
                            }
                            {
                                name: help_menu
                                only_buffer_difference: true
                                marker: "? "
                                type: {
                                    layout: description
                                    columns: 4
                                    col_width: 20 # If missing all the screen width is used to calculate column width.
                                    col_padding: 2
                                    selection_rows: 4
                                    description_rows: 10
                                }
                                style: {
                                    text: "#${colors.teal}"
                                    selected_text: {fg: "#${ui.bg.base}", bg: "#${colors.teal}", attr: "b"}
                                    description_text: {fg: "#${ui.fg.text}", attr: "i"}
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
                                event: { send: esc }    # NOTE: does not appear to work.
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
                                        {send: menuup}
                                        {send: up}
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
                                        {send: menudown}
                                        {send: down}
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
                                        {send: menuleft}
                                        {send: left}
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
                                        {send: historyhintcomplete}
                                        {send: menuright}
                                        {send: right}
                                    ]
                                }
                            }
                            {
                                name: move_one_word_left
                                modifier: control
                                keycode: left
                                mode: [emacs, vi_normal, vi_insert]
                                event: {edit: movewordleft}
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: control
                                keycode: right
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        {send: historyhintwordcomplete}
                                        {edit: movewordright}
                                    ]
                                }
                            }
                            {
                                name: move_to_line_start
                                modifier: none
                                keycode: home
                                mode: [emacs, vi_normal, vi_insert]
                                event: {edit: movetolinestart}
                            }
                            {
                                name: move_to_line_start
                                modifier: control
                                keycode: char_a
                                mode: [emacs, vi_normal, vi_insert]
                                event: {edit: movetolinestart}
                            }
                            {
                                name: move_to_line_end_or_take_history_hint
                                modifier: none
                                keycode: end
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        {send: historyhintcomplete}
                                        {edit: movetolineend}
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
                                        {send: historyhintcomplete}
                                        {edit: movetolineend}
                                    ]
                                }
                            }
                            {
                                name: move_to_line_start
                                modifier: control
                                keycode: home
                                mode: [emacs, vi_normal, vi_insert]
                                event: {edit: movetolinestart}
                            }
                            {
                                name: move_to_line_end
                                modifier: control
                                keycode: end
                                mode: [emacs, vi_normal, vi_insert]
                                event: {edit: movetolineend}
                            }
                            {
                                name: move_up
                                modifier: control
                                keycode: char_p
                                mode: [emacs, vi_normal, vi_insert]
                                event: {
                                    until: [
                                        {send: menuup}
                                        {send: up}
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
                                        {send: menudown}
                                        {send: down}
                                    ]
                                }
                            }
                            {
                                name: delete_one_character_backward
                                modifier: none
                                keycode: backspace
                                mode: [emacs, vi_insert]
                                event: {edit: backspace}
                            }
                            {
                                name: delete_one_word_backward
                                modifier: control
                                keycode: backspace
                                mode: [emacs, vi_insert]
                                event: {edit: backspaceword}
                            }
                            {
                                name: delete_one_character_forward
                                modifier: none
                                keycode: delete
                                mode: [emacs, vi_insert]
                                event: {edit: delete}
                            }
                            {
                                name: delete_one_character_forward
                                modifier: control
                                keycode: delete
                                mode: [emacs, vi_insert]
                                event: {edit: delete}
                            }
                            {
                                name: delete_one_character_forward
                                modifier: control
                                keycode: char_h
                                mode: [emacs, vi_insert]
                                event: {edit: backspace}
                            }
                            {
                                name: delete_one_word_backward
                                modifier: control
                                keycode: char_w
                                mode: [emacs, vi_insert]
                                event: {edit: backspaceword}
                            }
                            {
                                name: move_left
                                modifier: none
                                keycode: backspace
                                mode: vi_normal
                                event: {edit: moveleft}
                            }
                            {
                                name: newline_or_run_command
                                modifier: none
                                keycode: enter
                                mode: emacs
                                event: {send: enter}
                            }
                            {
                                name: move_left
                                modifier: control
                                keycode: char_b
                                mode: emacs
                                event: {
                                    until: [
                                        {send: menuleft}
                                        {send: left}
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
                                        {send: historyhintcomplete}
                                        {send: menuright}
                                        {send: right}
                                    ]
                                }
                            }
                            {
                                name: redo_change
                                modifier: control
                                keycode: char_g
                                mode: emacs
                                event: {edit: redo}
                            }
                            {
                                name: undo_change
                                modifier: control
                                keycode: char_z
                                mode: emacs
                                event: {edit: undo}
                            }
                            {
                                name: paste_before
                                modifier: control
                                keycode: char_y
                                mode: emacs
                                event: {edit: pastecutbufferbefore}
                            }
                            {
                                name: cut_word_left
                                modifier: control
                                keycode: char_w
                                mode: emacs
                                event: {edit: cutwordleft}
                            }
                            {
                                name: cut_line_to_end
                                modifier: control
                                keycode: char_k
                                mode: emacs
                                event: {edit: cuttoend}
                            }
                            {
                                name: cut_line_from_start
                                modifier: control
                                keycode: char_u
                                mode: emacs
                                event: {edit: cutfromstart}
                            }
                            {
                                name: swap_graphemes
                                modifier: control
                                keycode: char_t
                                mode: emacs
                                event: {edit: swapgraphemes}
                            }
                            {
                                name: move_one_word_left
                                modifier: alt
                                keycode: left
                                mode: emacs
                                event: {edit: movewordleft}
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: alt
                                keycode: right
                                mode: emacs
                                event: {
                                    until: [
                                        {send: historyhintwordcomplete}
                                        {edit: movewordright}
                                    ]
                                }
                            }
                            {
                                name: move_one_word_left
                                modifier: alt
                                keycode: char_b
                                mode: emacs
                                event: {edit: movewordleft}
                            }
                            {
                                name: move_one_word_right_or_take_history_hint
                                modifier: alt
                                keycode: char_f
                                mode: emacs
                                event: {
                                    until: [
                                        {send: historyhintwordcomplete}
                                        {edit: movewordright}
                                    ]
                                }
                            }
                            {
                                name: delete_one_word_forward
                                modifier: alt
                                keycode: delete
                                mode: emacs
                                event: {edit: deleteword}
                            }
                            {
                                name: delete_one_word_backward
                                modifier: alt
                                keycode: backspace
                                mode: emacs
                                event: {edit: backspaceword}
                            }
                            {
                                name: delete_one_word_backward
                                modifier: alt
                                keycode: char_m
                                mode: emacs
                                event: {edit: backspaceword}
                            }
                            {
                                name: cut_word_to_right
                                modifier: alt
                                keycode: char_d
                                mode: emacs
                                event: {edit: cutwordright}
                            }
                            {
                                name: upper_case_word
                                modifier: alt
                                keycode: char_u
                                mode: emacs
                                event: {edit: uppercaseword}
                            }
                            {
                                name: lower_case_word
                                modifier: alt
                                keycode: char_l
                                mode: emacs
                                event: {edit: lowercaseword}
                            }
                            {
                                name: capitalize_char
                                modifier: alt
                                keycode: char_c
                                mode: emacs
                                event: {edit: capitalizechar}
                            }
                        ]
                    }
                '';

                envFile.text = /* nu */ ''
                    def create_left_prompt [] {
                        let home = ($nu.home-path)

                        # Perform tilde substitution on dir.
                        # 
                        # To determine if the prefix of the path matches the home dir, we split the current path into
                        # segments, and compare those with the segments of the home dir. In cases where the current dir
                        # is a parent of the home dir (e.g. `/home`, homedir is `/home/user`), this comparison will 
                        # also evaluate to true. Inside the condition, we attempt to str replace `$home` with `~`.
                        # Inside the condition, either:
                        # 1. The home prefix will be replaced
                        # 2. The current dir is a parent of the home dir, so it will be uneffected by the str replace
                        let dir = (
                            if ($env.PWD | path split | zip ($home | path split) | all { $in.0 == $in.1 }) {
                                ($env.PWD | str replace $home "~")
                            } else {
                                $env.PWD
                            }
                        )

                        let path_color = (if (is-admin) { ansi red_bold } else { ansi magenta_bold })
                        let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_magenta_bold })
                        let path_segment = $"($path_color)($dir | path split | last 3 | path join)"

                        $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
                    }

                    def create_right_prompt [] {
                        # Create a right prompt in magenta with green separators and am/pm underlined.
                        let time_segment = ([
                            (ansi reset)
                            (ansi blue)
                            (date now | format date '%X %p') # try to respect user's locale
                        ]   | str join
                            | str replace --regex --all "([/:])" $"(ansi cyan)''${1}(ansi blue)"
                            | str replace --regex --all "([AP]M)" $"(ansi blue_underline)''${1}")

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
                    # $env.TRANSIENT_PROMPT_COMMAND = {|| "~> " }
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
                    $env.NU_LIB_DIRS = [
                        # FIXME: This default is not implemented in rust code as of 2023-09-06.
                        ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
                    ]

                    # Directories to search for plugin binaries when calling register.
                    $env.NU_PLUGIN_DIRS = [
                        # FIXME: This default is not implemented in rust code as of 2023-09-06.
                        ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
                    ]

                    # To add entries to PATH (on Windows you might use Path), you can use the following pattern:
                    $env.PATH = ($env.PATH | split row (char esep) | prepend '~/.cargo/bin/')
                    $env.LS_COLORS = "${config.aeon.theme.cli.ls}"

                    # Autostart an SSH agent and don't start more than one of it.
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
