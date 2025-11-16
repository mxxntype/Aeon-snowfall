{ lib, ... }:

{
    generators.stylesheets.nixos-search = { theme }: let
        metadata = /* css */ ''
            @preprocessor less
            @var select lightFlavor "Light Flavor" ["latte:Latte*", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha"]
            @var select darkFlavor "Dark Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
            @var select accentColor "Accent" ["rosewater:Rosewater", "flamingo:Flamingo", "pink:Pink", "mauve:Mauve*", "red:Red", "maroon:Maroon", "peach:Peach", "yellow:Yellow", "green:Green", "teal:Teal", "blue:Blue", "sapphire:Sapphire", "sky:Sky", "lavender:Lavender", "subtext0:Gray"]
        '';

        stylesheet = /* css */ ''
            @-moz-document domain("search.nixos.org") {
                :root {
                    @media (prefers-color-scheme: light) {
                        #catppuccin(@lightFlavor);
                    }
                    @media (prefers-color-scheme: dark) {
                        #catppuccin(@darkFlavor);
                    }
                }

                #catppuccin(@flavor) {
                    #lib.palette();

                    --background-color: @base;
                    --badge-background: @accent;
                    --button-active-background: @surface1;
                    --button-active-hover-background: @surface2;
                    --button-background: @surface0;
                    --button-hover-background: @surface2;
                    --color-active-hover-tab: @surface1;
                    --color-active-tab: @surface0;
                    --color-hover-tab: @surface1;
                    --headerbar-background-color: @mantle;
                    --hover-background: @surface0;
                    --link-color: @accent;
                    --info-label-background: @accent;
                    --dark-blue: @accent;
                    --light-blue: @accent; // used by focus outline
                    --line-color: @surface0;
                    --search-result-short-details-color: @subtext1;
                    --search-result-divider-line-color: @surface0;
                    --search-result-title-color: @accent;
                    --search-sidebar-link-color: @text;
                    --search-sidebar-selected-link-background: @accent;
                    --search-sidebar-selected-link-color: @crust;
                    --terminal-background: @surface0;
                    --terminal-color: @red;
                    --text-color: @text;
                    --text-color-light: @text;
                    --text-color-warning: @yellow;

                    // hardcoded to #fff
                    .label,
                    .badge {
                        color: @crust;
                    }

                    // hardcoded to #005580
                    a:hover,
                    a:focus {
                        color: @text;
                    }
                }
            }
        '';
    in lib.aeon.generators.stylesheets.fromCatppuccin.intoDynamicStylesheet {
        name = "search.nixos.org";
        inherit metadata stylesheet theme;
    };
}
