# INFO: Home-manager Helix module.
#
# https://helix-editor.com

{
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
        programs.nushell.environmentVariables.EDITOR = "hx";
        programs.helix = {
            enable = true;
            defaultEditor = true; # BUG: Isn't recognized by Nushell.
            settings = {
                # theme = "nix"; # TODO.
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
                        ];
                        center = [
                            "file-name"
                            "file-modification-indicator"
                        ];
                        right = [
                            "diagnostics"
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
                        # TODO: Match with Nushell bindings?
                        #
                        # Navigation in INSERT mode.
                        "A-h" = "move_char_left";
                        "A-j" = "move_line_down";
                        "A-k" = "move_line_up";
                        "A-l" = "move_char_right";
                    };
                };
            };

            # Language and LSP config.
            languages = {
                language = [
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

                    {
                        name = "javascript";
                        auto-format = true;
                        language-servers = [
                            {
                                name = "typescript-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    }

                    {
                        name = "typescript";
                        auto-format = true;
                        language-servers = [
                            {
                                name = "typescript-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    }

                    {
                        name = "tsx";
                        auto-format = true;
                        language-servers = [
                            {
                                name = "typescript-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    }

                    {
                        name = "jsx";
                        auto-format = true;
                        language-servers = [
                            {
                                name = "typescript-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
                    }

                    {
                        name = "json";
                        language-servers = [
                            {
                                name = "json-language-server";
                                except-features = [ "format" ];
                            }
                            "biome"
                        ];
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
                ];

                language-server = {
                    # LANG: JavaScript
                    #
                    # An all-in-one, versatile LSP for JS/TS.
                    biome = {
                        command = "${pkgs.biome}/bin/biome";
                        args = [ "lsp-proxy" ];
                    };

                    # LANG: Any.
                    #
                    # GitHub Copilot inside of Helix.
                    helix-gpt = {
                        command = "helix-gpt";
                        args = [ "--handler" "copilot" ];
                    };

                    # LANG: Python.
                    #
                    # Type checker for the Python language.
                    pyright = {
                        config.python.analysis.typeCheckingMode = "basic";
                    };

                    # An extremely fast Python linter, in Rust.
                    ruff = {
                        command = "${pkgs.ruff-lsp}/bin/ruff-lsp";
                        config.settings.args = [ "--ignore" "E501" ];
                    };
                };
            };
        };
    };
}
