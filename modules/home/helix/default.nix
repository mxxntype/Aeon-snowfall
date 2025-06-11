# INFO: Home-manager Helix module.
#
# https://helix-editor.com

{
    inputs,
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.helix = {
        enable = mkOption {
            description = "Whether to enable the Helix editor";
            type = with types; bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.helix)
            enable
            ;
    in mkIf enable {
        programs.helix = {
            package = pkgs.aeon.helix;
            enable = true;
            defaultEditor = true;
            settings = {
                theme = if (config.aeon.style.themeFallbacks.helix != null)
                        then config.aeon.style.themeFallbacks.helix
                        else "nix";

                editor = {
                    idle-timeout = 0;
                    completion-trigger-len = 1;
                    file-picker.hidden = false;
                    lsp.display-messages = true;
                    indent-guides.render = true;
                    soft-wrap.enable = false;

                    end-of-line-diagnostics = "hint";
                    inline-diagnostics.cursor-line = "error";

                    color-modes = true;
                    cursor-shape = {
                        normal = "block";
                        insert = "bar";
                        select = "underline";
                    };

                    statusline = {
                        left = [
                            "mode"
                            "spinner"
                            "version-control"
                            "diagnostics"
                        ];
                        center = [
                            "file-name"
                            "file-modification-indicator"
                        ];
                        right = [
                            "position"
                            "file-encoding"
                            "file-type"
                        ];

                        mode = let icon = "hx:"; in {
                            normal = "${icon}NORMAL";
                            insert = "${icon}INSERT";
                            select = "${icon}SELECT";
                        };
                    };
                };

                keys = {
                    insert = {
                        "A-h" = "move_char_left";
                        "A-j" = "move_line_down";
                        "A-k" = "move_line_up";
                        "A-l" = "move_char_right";
                    };

                    normal = {
                        "A-e" = "file_picker";
                        "A-f" = "file_picker_in_current_directory";
                        space = {
                            i = "jump_forward";  # Jump further Inside.
                            o = "jump_backward"; # Jump further Outside.
                        };
                    };
                };
            };

            # Language and LSP config.
            languages = {
                language = let
                    # A shorthand for creating a configuration for a JS-like language.
                    mkJSDialect = { name }: {
                        inherit name;
                        auto-format = true;
                        language-servers = [
                            {
                                name = "typescript-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    };

                    # A shorthand for configuring JSON / JSON5.
                    mkJSON = { name }: {
                        inherit name;
                        language-servers = [
                            {
                                name = "json-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    };
                in [
                    {
                        name = "rust";
                        auto-format = true;
                    }

                    {
                        name = "c";
                        auto-format = true;
                    }

                    {
                        name = "cpp";
                        auto-format = true;
                    }

                    {
                        name = "nix";
                        indent = {
                            tab-width = 4;
                            unit = "    ";
                        };
                    }

                    # These have literally the same configuration.
                    (mkJSDialect { name = "javascript"; })
                    (mkJSDialect { name = "typescript"; })
                    (mkJSDialect { name = "jsx"; })
                    (mkJSDialect { name = "tsx"; })

                    # And these too.
                    (mkJSON { name = "json";  })
                    (mkJSON { name = "json5"; })

                    {
                        name = "toml";
                        auto-format = true;
                        formatter = let
                            taploConfig = pkgs.writeTextFile {
                                name = "taplo.toml";
                                text = /* toml */ ''
                                    [formatting]
                                    indent_string = "    "
                                '';
                            };
                        in {
                            command = "${pkgs.taplo}/bin/taplo";
                            args = [ "fmt" "--config" "${taploConfig}" "-" ];
                        };
                    }

                    {
                        name = "java";
                        auto-format = true;
                        indent = {
                            tab-width = 4;
                            unit = "    ";
                        };
                        formatter = {
                            command = "${pkgs.google-java-format}/bin/google-java-format";
                            args = [ "--aosp" "-" ];
                        };
                    }

                    {
                        name = "python";
                        auto-format = true;
                        language-servers = [ "pyright" "ruff" "pylsp" ];
                        formatter = {
                            command = "${pkgs.black}/bin/black";
                            args = [ "--quiet" "-" ];
                        };
                    }

                    # A new markup-based typesetting system that is powerful and easy to learn.
                    {
                        name = "typst";
                        auto-format = true;
                        language-servers = [ "typst-lsp" ];
                        formatter = {
                            command = "${pkgs.aeon.prettypst}/bin/prettypst";
                            args = [ "--use-std-in" "--use-std-out" "--style=otbs" ];
                        };
                    }
                ];

                language-server = {
                    # Make RA show hints from clippy as well.
                    rust-analyzer.config.check.command = "clippy";

                    # An all-in-one, versatile LSP for JS/TS.
                    biome = {
                        command = "${pkgs.biome}/bin/biome";
                        args = [ "lsp-proxy" ];
                    };

                    # GitHub Copilot inside of Helix.
                    helix-gpt = {
                        command = "${pkgs.helix-gpt}/bin/helix-gpt";
                        args = [ "--handler" "copilot" ];
                    };

                    # Type checker for the Python language.
                    pyright.config.python.analysis.typeCheckingMode = "basic";

                    # An extremely fast Python linter, in Rust.
                    # ruff = {
                    #     command = "${pkgs.ruff-lsp}/bin/ruff-lsp";
                    #     config.settings.args = [ "--ignore" "E501" ];
                    # };

                    # The open-source JavaScript runtime for the modern web (LSP).
                    deno-lsp = {
                        command = "${pkgs.deno}/bin/deno";
                        args = [ "lsp" ];
                        environment.NO_COLOR = "1"; 
                        config.deno = {
                            enable = true;
                            suggest = {
                                imports.hosts."https://deno.land" = true;
                            };
                        };
                    };

                    qmlls = {
                        args = [ "-E" ];
                        command = "qmlls";
                    };
                };
            };
        };

        home.packages = with pkgs; [
            black
            inputs.nil-fork.packages.${system}.nil
            pyright
            ruff
            marksman # Markdown LSP.
            taplo    # TOML LSP.
        ];

        # NOTE: Based on the Kanagawa theme.
        #
        # Stolen from https://github.com/helix-editor/helix/blob/master/runtime/themes/kanagawa.toml.
        xdg.configFile."helix/themes/nix.toml".text = let
            inherit (config.aeon.theme)
                code
                colors
                diff
                ui
                ;
        in /* toml */ ''
            "ui.selection" = { bg = "#${ui.bg.surface1}" }
            "ui.selection.primary" = { bg = "#${ui.bg.surface1}" }
            "ui.background" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.base}" }

            "ui.linenr" = { bg = "#${ui.bg.crust}", fg = "#${code.linenr}" }
            "ui.linenr.selected" = { fg = "#${code.linenrActive}", modifiers = ["bold"] }
            "ui.gutter" = { fg = "#${code.linenr}", bg = "#${ui.bg.crust}" }

            "ui.virtual" = "#${ui.bg.surface1}"
            "ui.virtual.ruler" = { bg = "#${ui.bg.surface0}" }
            "ui.virtual.inlay-hint" = "#${ui.fg.subtext0}"
            "ui.virtual.jump-label" = { fg = "#${ui.accent}", modifiers = ["bold"] }

            "ui.statusline" = { fg = "#${ui.fg.subtext1}", bg = "#${ui.bg.crust}" }
            "ui.statusline.inactive" = { fg = "#${ui.bg.surface0}", bg = "#${ui.bg.crust}" }
            "ui.statusline.normal" = { fg = "#${ui.bg.base}", bg = "#${colors.blue}", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "#${ui.bg.base}", bg = "#${colors.mauve}", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "#${ui.bg.base}", bg = "#${colors.green}", modifiers = ["bold"] }

            "ui.bufferline" = { fg = "#${ui.fg.subtext0}", bg = "#${ui.bg.base}" }
            "ui.bufferline.active" = { fg = "#${ui.fg.subtext0}", bg = "#${ui.bg.base}" }
            "ui.bufferline.background" = { bg = "#${ui.bg.base}" }

            "ui.popup" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.base}" }
            "ui.window" = { fg = "#${ui.bg.base}" }
            "ui.help" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.base}" }
            "ui.text" = "#${ui.fg.text}"
            "ui.text.focus" = { fg = "#${ui.fg.text}", bg = "#${colors.blue}", modifiers = ["bold"] }

            "ui.cursor" = { fg = "#${ui.accent}", bg = "#${ui.bg.surface1}" }
            "ui.cursor.primary" = { fg = "#${ui.accent}", bg = "#${ui.fg.text}" }
            "ui.cursor.match" = { fg = "#${ui.warning}", modifiers = ["bold"] }
            "ui.highlight" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.surface1}" }
            "ui.menu" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.crust}" }
            "ui.menu.selected" = { fg = "#${ui.fg.text}", bg = "#${ui.bg.surface0}", modifiers = ["bold"] }
            "ui.menu.scroll" = { fg = "#${ui.fg.subtext0}", bg = "#${ui.bg.crust}" }

            "ui.cursorline.primary" = { bg = "#${ui.bg.surface2}" }
            "ui.cursorcolumn.primary" = { bg = "#${ui.bg.surface2}" }

            "ui.debug.breakpoint" = "#${ui.warning}"
            "ui.debug.active" = "#${ui.accent}"

            "diagnostic.error" = { underline = { color = "#${ui.error}", style = "curl" } }
            "diagnostic.warning" = { underline = { color = "#${ui.warning}", style = "curl" } }
            "diagnostic.info" = { underline = { color = "#${ui.info}", style = "curl" } }
            "diagnostic.hint" = { underline = { color = "#${ui.subtle}", style = "curl" } }
            "diagnostic.unnecessary" = { modifiers = ["dim"] }
            "diagnostic.deprecated" = { modifiers = ["crossed_out"] }

            error = "#${ui.error}"
            warning = "#${ui.warning}"
            info = "#${ui.info}"
            hint = "#${ui.subtle}"

            "diff.plus" = "#${diff.plus}"
            "diff.minus" = "#${diff.minus}"
            "diff.delta" = "#${diff.delta}"

            "attribute" = "#${code.field}"
            "type" = "#${code.type}"
            "type.builtin" = "#${code.type}"
            "constructor" = "#${code.function}"
            "constant" = "#${code.constant}"
            "constant.numeric" = "#${code.number}"
            "constant.character.escape" = { fg = "#${code.escape}", modifiers = ["bold"] }
            "string" = "#${code.string}"
            "string.regexp" = "#${code.pattern}"
            "string.special.url" = "#${code.url}"
            "string.special.symbol" = "#${code.pattern}"
            "comment" = "#${code.comment}"
            "variable" = "#${ui.fg.text}"
            "variable.builtin" = "#${code.parameter}"
            "variable.parameter" = "#${code.parameter}"
            "variable.other.member" = "#${code.field}"
            "label" = "#${code.url}"
            "punctuation" = "#${code.punctuation}"
            "keyword" = { fg = "#${code.keyword}", modifiers = ["italic"] }
            "keyword.control.return" = "#${code.keyword}"
            "keyword.control.exception" = "#${ui.error}"
            "keyword.directive" = "#${code.keyword}"
            "operator" = "#${code.operator.math}"
            "function" = "#${code.function}"
            "function.builtin" = "#${code.function}"
            "function.macro" = "#${code.macro}"
            "tag" = "#${code.namespace}"
            "namespace" = "#${code.namespace}"
            "special" = "#${ui.accent}"

            "markup.heading" = { fg = "#${colors.mauve}", modifiers = ["bold"] }
            "markup.heading.marker" = "#${colors.red}"
            "markup.heading.1" = { fg = "#${colors.mauve}", modifiers = ["bold"] }
            "markup.heading.2" = { fg = "#${colors.blue}", modifiers = ["bold"] }
            "markup.heading.3" = { fg = "#${colors.peach}", modifiers = ["bold"] }
            "markup.list" = "#${colors.pink}"
            "markup.bold" = { modifiers = ["bold"] }
            "markup.italic" = { modifiers = ["italic"] }
            "markup.strikethrough" = { modifiers = ["crossed_out"] }
            "markup.link.text" = { fg = "#${code.url}" }
            "markup.link.url" = { fg = "#${code.url}" }
            "markup.link.label" = "#${ui.warning}"
            "markup.quote" = "#${colors.mauve}"
            "markup.raw" = "#${code.string}"
        '';
    };
}
