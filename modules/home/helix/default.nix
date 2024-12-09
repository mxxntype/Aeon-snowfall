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

                        mode = let icon = "󰚄"; in {
                            normal = "${icon} NORMAL";
                            insert = "${icon} INSERT";
                            select = "${icon} SELECT";
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
                    ruff = {
                        command = "${pkgs.ruff-lsp}/bin/ruff-lsp";
                        config.settings.args = [ "--ignore" "E501" ];
                    };

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
                };
            };
        };

        home.packages = with pkgs; [
            black
            inputs.nil-fork.packages.${system}.nil
            nodePackages.pyright
            ruff
            taplo
        ];
    };
}
