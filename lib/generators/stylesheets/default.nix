{ ... }:

{
    generators.stylesheets = {
        fromCatppuccin = rec {
            defaultKeywords = [
                "rosewater"
                "flamingo"
                "pink"
                "mauve"
                "red"
                "maroon"
                "peach"
                "yellow"
                "green"
                "teal"
                "sky"
                "sapphire"
                "blue"
                "lavender"
                "text"
                "subtext1"
                "subtext0"
                "overlay2"
                "overlay1"
                "overlay0"
                "surface2"
                "surface1"
                "surface0"
                "base"
                "mantle"
                "crust"
            ];

            defaultReferences = []
                ++ (defaultKeywords |> map (keyword: "@{${keyword}}"))
                # ++ (defaultKeywords |> map (keyword: "${keyword}:"))
                ++ (defaultKeywords |> map (keyword: "@${keyword}"));

            defaultReplacements = { theme }: []
                ++ (defaultKeywords |> map (keyword: "#${theme.colors.${keyword}}"))
                # ++ (defaultKeywords |> map (keyword: "#${theme.colors.${keyword}}:"))
                ++ (defaultKeywords |> map (keyword: "#${theme.colors.${keyword}}"));

            variableMixin = {
                theme ? throw "A theme must be provided to generate the variableMixin"
            }:
                # WARN: I do not have the slightest clue what the fuck happens below, CSS is a nightmare.
                with theme.colors; /* css */ ''
                    @colors: {
                        @raw: {
                            @rosewater: #${rosewater};
                            @flamingo: #${flamingo};
                            @pink: #${pink};
                            @mauve: #${mauve};
                            @red: #${red};
                            @maroon: #${maroon};
                            @peach: #${peach};
                            @yellow: #${yellow};
                            @green: #${green};
                            @teal: #${teal};
                            @sky: #${sky};
                            @sapphire: #${sapphire};
                            @blue: #${blue};
                            @lavender: #${lavender};
                            @text: #${text};
                            @subtext1: #${subtext1};
                            @subtext0: #${subtext0};
                            @overlay2: #${overlay2};
                            @overlay1: #${overlay1};
                            @overlay0: #${overlay0};
                            @surface2: #${surface2};
                            @surface1: #${surface1};
                            @surface0: #${surface0};
                            @base: #${base};
                            @mantle: #${mantle};
                            @crust: #${crust};
                        };
                    };
                  
                    #lib {
                        .palette() {
                            @accent: @colors[@raw][@@accentColor];
                        }
                    }
                '';
            
            intoDynamicStylesheet = {
                metadata ? throw "The stylesheet's metadata was not provided",
                stylesheet ? throw "The CSS stylesheet was not provided",
                theme ? throw "A theme must be provided to generate the stylesheet",
                references ? defaultReferences,
                replacements ? (defaultReplacements { inherit theme; }),
            }:
                assert builtins.isString metadata;
                assert builtins.isString stylesheet;
                builtins.concatStringsSep "\n" [
                    (metadata)
                    (variableMixin { inherit theme; })
                    (builtins.replaceStrings references replacements stylesheet)    
                ];
        };
    };
}
