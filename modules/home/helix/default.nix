# INFO: Home-manager Helix module.
#
# https://helix-editor.com

{
    config,
    lib,
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

    config = mkIf config.aeon.helix.enable {
        programs.nushell.environmentVariables.EDITOR = "hx";
        programs.helix = {
            enable = true;
            defaultEditor = true; # BUG: Isn't recognized by Nushell.
            settings = {
                # theme = "nix"; # TODO
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

                        mode = {
                            normal = "󰚄 NORMAL";
                            insert = "󰚄 INSERT";
                            select = "󰚄 SELECT";
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

            languages.language = [
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
            ];
        };
    };
}
