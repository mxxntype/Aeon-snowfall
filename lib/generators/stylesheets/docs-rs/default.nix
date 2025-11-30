{ lib, ... }:

{
    generators.stylesheets.docs-rs = {
        theme ? throw "A theme must be provided to generate the docs.rs stylesheet",
        fonts,
        homeDirectory ? "A home directory must be provided to support local 'file://' URLs",
    }: let
        metadata = /* css */ ''
            @preprocessor less
            @var select lightFlavor "Light Flavor" ["latte:Latte*", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha"]
            @var select darkFlavor "Dark Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
            @var select accentColor "Accent" ["rosewater:Rosewater", "flamingo:Flamingo", "pink:Pink", "mauve:Mauve*", "red:Red", "maroon:Maroon", "peach:Peach", "yellow:Yellow", "green:Green", "teal:Teal", "blue:Blue", "sapphire:Sapphire", "sky:Sky", "lavender:Lavender", "subtext0:Gray"]
        '';

        stylesheet = /* css */ ''
            @-moz-document
                domain("doc.rust-lang.org"),
                domain("docs.embassy.dev"),
                domain("docs.espressif.com"),
                domain("docs.rs"),
                url-prefix("file://${homeDirectory}/.rustup/toolchains"),
                url-prefix("file://${homeDirectory}/Work/rsensor/target/doc"),
            {
                :root:not([data-docs-rs-theme]) {
                    @media (prefers-color-scheme: light) {
                        #catppuccin();
                    }
                    @media (prefers-color-scheme: dark) {
                        #catppuccin();
                    }
                }
                :root[data-docs-rs-theme="dark"] {
                    #catppuccin();
                }
                :root[data-docs-rs-theme="light"] {
                    #catppuccin();
                }

                #catppuccin() {
                    #lib.palette();

                    --color-background-code: @mantle;
                    --color-background: @base;
                    --input-color: @text;
                    --input-box-shadow-focus: 0 0 8px 4px @accent;
                    --color-border-light: @surface2;
                    --color-border: @surface0;
                    --color-doc-link-background: @accent;
                    --color-doc-link-hover: @accent;
                    --color-error-hover: red;
                    --color-error: red;
                    --color-macro: red;
                    --color-menu-border: red;
                    --color-menu-header-background: red;
                    --color-navbar-standard: @text;
                    --color-standard: @subtext1;
                    --color-brand: @text;
                    --color-struct: red;
                    --color-type: @peach;
                    --color-url: @accent;
                    --color-warn-background: @peach;
                    --color-warn-msg: @crust;
                    --color-warn-hover: red;
                    --color-warn: @peach;
                    --color-background-input: @mantle;
                    --color-table-header-background: @surface0;
                    --color-table-header: @text;
                    --color-search-focus: red;
                    --chart-title-color: red;
                    --chart-grid: red;

                    --main-background-color: @base;
                    --main-color: @text;
                    --settings-input-color: @accent;
                    --settings-input-border-color: @surface0;
                    --settings-button-color: @text;
                    --settings-button-border-focus: @accent;
                    --sidebar-background-color: @mantle;
                    --sidebar-background-color-hover: @crust;
                    --source-sidebar-background-selected: @surface0;
                    --source-sidebar-background-hover: @base;
                    --code-block-background-color: @mantle;
                    --headings-border-bottom-color: @overlay1;
                    --border-color: @surface0;
                    --button-background-color: @mantle;
                    --right-side-color: @surface2;
                    --code-attribute-color: @yellow;
                    --toggles-color: @subtext1;
                    --search-input-focused-border-color: @accent;
                    --copy-path-button-color: @text;
                    --codeblock-error-hover-color: @red;
                    --codeblock-error-color: fade(@red, 70%);
                    --codeblock-ignore-hover-color: @red;
                    --codeblock-ignore-color: fade(@red, 70%);
                    --warning-border-color: red;
                    --type-link-color: @sky;
                    --trait-link-color: @mauve;
                    --assoc-item-link-color: @yellow;
                    --function-link-color: @green;
                    --macro-link-color: @green;
                    --keyword-link-color: @yellow;
                    --mod-link-color: @accent;
                    --link-color: @accent;
                    --sidebar-link-color: @accent;
                    --sidebar-current-link-background-color: @surface0;
                    --search-result-link-focus-background-color: fade(@accent, 20%);
                    --search-result-border-color: @surface0;
                    --search-color: @text;
                    --search-error-code-background-color: red;
                    --search-results-alias-color: red;
                    --search-results-grey-color: @subtext1;
                    --search-tab-title-count-color: @subtext0;
                    --search-tab-button-not-selected-border-top-color: @crust;
                    --search-tab-button-not-selected-background: @crust;
                    --search-tab-button-selected-border-top-color: @accent;
                    --search-tab-button-selected-background: @base;
                    --stab-background-color: @surface0;
                    --stab-code-color: @accent;
                    --code-highlight-kw-color: @mauve;
                    --code-highlight-kw-2-color: @mauve;
                    --code-highlight-lifetime-color: @blue;
                    --code-highlight-prelude-color: @yellow;
                    --code-highlight-prelude-val-color: @yellow;
                    --code-highlight-number-color: @peach;
                    --code-highlight-string-color: @green;
                    --code-highlight-literal-color: @red;
                    --code-highlight-attribute-color: @yellow;
                    --code-highlight-self-color: @red;
                    --code-highlight-macro-color: @blue;
                    --code-highlight-question-mark-color: @teal;
                    --code-highlight-comment-color: @overlay2;
                    --code-highlight-doc-comment-color: @overlay2;
                    --color-syntax-foreground: inherit;
                    --color-syntax-attribute: @yellow;
                    --color-syntax-background: @mantle;
                    --color-syntax-bool: @red;
                    --color-syntax-comment: @overlay2;
                    --color-syntax-doc-comment: @overlay2;
                    --color-syntax-keyword1: @mauve;
                    --color-syntax-keyword2: @mauve;
                    --color-syntax-lifetime: @blue;
                    --color-syntax-macro: @blue;
                    --color-syntax-number: @peach;
                    --color-syntax-prelude-ty: @yellow;
                    --color-syntax-prelude-val: @yellow;
                    --color-syntax-question-mark: @teal;
                    --color-syntax-self: @red;
                    --color-syntax-string: @green;
                    --src-line-numbers-span-color: @accent;
                    --src-line-number-highlighted-background-color: fade(@accent, 30%);
                    --test-arrow-color: #dedede;
                    --test-arrow-background-color: red;
                    --test-arrow-hover-color: #dedede;
                    --test-arrow-hover-background-color: red;
                    --target-background-color: fade(@accent, 10%);
                    --target-border-color: @accent;
                    --kbd-color: @text;
                    --kbd-background: @mantle;
                    --kbd-box-shadow-color: @surface1;
                    --crate-search-hover-border: red;
                    --src-sidebar-background-selected: @surface0;
                    --src-sidebar-background-hover: @surface1;
                    --table-alt-row-background-color: @mantle;
                    --codeblock-link-background: fade(@surface0, 50%);
                    --scrape-example-toggle-line-background: red;
                    --scrape-example-toggle-line-hover-background: red;
                    --scrape-example-code-line-highlight: fade(@accent, 40%);
                    --scrape-example-code-line-highlight-focus: fade(@accent, 40%);
                    --scrape-example-help-border-color: @subtext0;
                    --scrape-example-help-color: @subtext1;
                    --scrape-example-help-hover-border-color: @text;
                    --scrape-example-help-hover-color: @text;
                    --scrape-example-code-wrapper-background-start: @base;
                    --scrape-example-code-wrapper-background-end: @base;
                    --sidebar-resizer-hover: @sky;
                    --sidebar-resizer-active: @sapphire;

                    html, body {
                        font-family: "${fonts.text}", sans-serif !important;
                    }

                    code, pre, tt {
                        font-family: "${fonts.code}", monospace !important;
                    }

                    select {
                        background-color: @mantle;
                        border-color: @surface0;
                    }

                    hr {
                        border-color: @overlay1;
                    }

                    .sidebar {
                        border-right: none;
                    }

                    .pure-menu-link {
                        color: @subtext0;

                        &:hover {
                            color: @text;
                        }
                    }

                    .pure-table {
                        &,
                        td,
                        th {
                            border-color: @surface0;
                        }
                    }
                }
            }
        '';
    in lib.aeon.generators.stylesheets.fromCatppuccin.intoDynamicStylesheet {
        name = "docs.rs";
        inherit metadata stylesheet theme;
    };
}
