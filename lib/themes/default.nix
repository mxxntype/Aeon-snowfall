# INFO: Theming utilities.
#
# The sole reason for all of this is that themes should not be just sets of freestanding colors.
# They should also contain guidelines that describe where and when the colors should be used.
#
# A great example would be syntax highlighting.
# - Catppuccin Mocha uses a lot of blue, purple and yellow;
# - Everforest basically does not use blue, almost everything is red, green or yellow;
# - Github uses a lot of red, blue and orange, and strings are suddenly light blue.
#
# Mapping stuff to hardcoded color names (`functions = blue, variables = white`)
# works, but discards all of these theme-specific aspects, and eventually the only theme
# that looks right is the one that was used when the rules were written. Not good.
#
# This is my solution: pair each theme with some attrsets of `color_name` -> `hex_code`,
# But rather `use_case / thing / scope` -> `color_name`, and make them overridable.
# Functions below are helpers to generate a theme with default mappings, and override
# those if need be.
#
# And well yes, I do care THAT much about theming.

{
    lib,
    ...
}:

{
    # INFO: Makes a theme template from colors and metadata.
    # The resulting template should be passed to `mkTheme`.
    #
    # Base colors:
    #   'void'     - Pitch black or full white.
    #   'crust'    - Darkest background.
    #   'mantle'   - Darker background.
    #   'base'     - Default background.
    #   'surface0' - Default surface (i.e. for a button).
    #   'surface1' - Brighter surface.
    #   'surface2' - Even brighter surface.
    #   'overlay0' - Surface on a surface...
    #   'overlay1' - Brighter surface on a surface.
    #   'subtext0' - Darkest text (comments).
    #   'subtext1' - Darker text.
    #   'text'     - Default text.
    #
    # Accent colors:
    #   'red'       - Well.
    #   'maroon'    - Desaturated red.
    #   'peach'     - Most saturated orange.
    #   'flamingo'  - Desaturated orange.
    #   'rosewater' - Pale yellow.
    #   'yellow'    - Oh.
    #   'green'     - ...
    #   'cyan'      - 
    #   'teal'      - ...
    #   'sky'       - Blueish green.
    #   'sapphire'  - Greenish blue.
    #   'blue'      - Blue. Literally.
    #   'lavender'  - Pale blue or pink.
    #   'mauve'     - Purple.
    #   'pink'      - ...
    #
    # Meta is anything, really.
    mkThemeTemplate = {
        colors,
        meta ? {},
    }: rec {
        ui = with colors; {
            bg = {
                inherit void crust mantle base;
                inherit surface0 surface1 surface2;
                inherit overlay0 overlay1;
            };

            fg = {
                inherit subtext0 subtext1;
                inherit text;
            };

            # For light stuff in dark themes & vice versa.
            alternate = {
                bg = {
                    base = text;
                    surface = subtext1;
                };
                fg = {
                    subtext = base;
                    text = void;
                };
            };

            accent = mauve;
            subtle = lavender;
            info   = sky;
            ok     = green;
            warn   = yellow;
            error  = red;
        };

        # Syntax highlighting colors. TODO: Add more.
        code = with colors; {
            keyword      = mauve;
            variable     = text;
            argument     = maroon;
            field        = teal;
            namespace    = blue;
            type         = yellow;
            struct       = code.type;
            enum         = sky;
            function     = blue;
            macro        = mauve;
            use          = mauve;
            primitive    = peach;
            number       = code.primitive;
            boolean      = code.primitive;
            constant     = peach;
            string       = green;
            char         = green;
            escape       = pink;
            comment      = subtext0;
            linenr       = code.comment;
            linenrActive = ui.accent;
            url          = teal;
        };

        # Shell colors.
        cli = with colors; {
            builtin  = teal;
            external = blue;
            notfound = red;
            argument = teal;

            # TODO: Make LS_COLORS overridable?
            # ls = {};
        };

        # VCS stuff.
        diff = with colors; {
            plus = green;
            minus = red;
            delta = blue;
        };

        inherit colors meta;
    };

    # INFO: Apply theme-specific overrides to a theme template.
    mkTheme = {
        themeTemplate,
        overrides ? {},
    }: lib.recursiveUpdate themeTemplate overrides;

    # INFO: Convert an "RRBBGG" hex color code to a "RRR, GGG, BBB" decimal one.
    hexToDecimal = hexCode: separator:
        assert builtins.isString hexCode;
        assert builtins.stringLength hexCode == 6;
        assert builtins.isString separator;
        let
            # NOTE: Horrible, but I could not figure out a better way...
            _map = {
                "0" = 0;
                "1" = 1;
                "2" = 2;
                "3" = 3;
                "4" = 4;
                "5" = 5;
                "6" = 6;
                "7" = 7;
                "8" = 8;
                "9" = 9;
                "a" = 10;
                "A" = 10;
                "b" = 11;
                "B" = 11;
                "c" = 12;
                "C" = 12; "d" = 13;
                "D" = 13;
                "e" = 14;
                "E" = 14;
                "f" = 15;
                "F" = 15;
            };
            index = pos: string: builtins.substring pos 1 string;
            colors = {
                red = _map.${index 0 hexCode} * 16 + _map.${index 1 hexCode};
                green = _map.${index 2 hexCode} * 16 + _map.${index 3 hexCode};
                blue = _map.${index 4 hexCode} * 16 + _map.${index 5 hexCode};
            };
            separateWith = separator: builtins.concatStringsSep separator [
                (toString colors.red)
                (toString colors.green)
                (toString colors.blue)
            ];
        in separateWith separator;
}
