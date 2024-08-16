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

rec {
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
            path         = blue;
            primitive    = peach;
            number       = code.primitive;
            boolean      = code.primitive;
            constant     = peach;
            string       = green;
            char         = green;
            escape       = pink;
            pattern      = peach;
            comment      = subtext0;
            linenr       = code.comment;
            linenrActive = ui.accent;
            url          = teal;
            punctuation  = subtext0;
            range        = yellow;
            operator = {
                math = subtext0;
                logic = mauve;
            };
        };

        # Shell colors.
        cli = with colors; {
            builtin  = teal;
            external = blue;
            notfound = red;
            argument = teal;

            ls = builtins.replaceStrings [ "\n" ] [ ":" ] ''
                *~=0;38;2;${hexToDecimal surface2 ";"}
                bd=0;38;2;${hexToDecimal sapphire ";"};48;2;${hexToDecimal surface0 ";"}
                ca=0
                cd=0;38;2;${hexToDecimal pink ";"};48;2;${hexToDecimal surface0 ";"}
                di=0;38;2;${hexToDecimal blue ";"}
                do=0;38;2;${hexToDecimal crust ";"};48;2;${hexToDecimal pink ";"}
                ex=1;38;2;${hexToDecimal red ";"}
                fi=0
                ln=0;38;2;${hexToDecimal pink ";"}
                mh=0
                mi=0;38;2;${hexToDecimal crust ";"};48;2;${hexToDecimal red ";"}
                no=0
                or=0;38;2;${hexToDecimal crust ";"};48;2;${hexToDecimal red ";"}
                ow=0
                pi=0;38;2;${hexToDecimal crust ";"};48;2;${hexToDecimal blue ";"}
                rs=0
                sg=0
                so=0;38;2;${hexToDecimal crust ";"};48;2;${hexToDecimal pink ";"}
                st=0
                su=0
                tw=0
                *=0;38;2;${hexToDecimal text ";"}
                *.7z=4;38;2;${hexToDecimal sapphire ";"}
                *.CFUserTextEncoding=0;38;2;${hexToDecimal surface2 ";"}
                *.DS_Store=0;38;2;${hexToDecimal surface2 ";"}
                *.a=1;38;2;${hexToDecimal red ";"}
                *.aif=0;38;2;${hexToDecimal flamingo ";"}
                *.ape=0;38;2;${hexToDecimal flamingo ";"}
                *.apk=4;38;2;${hexToDecimal sapphire ";"}
                *.applescript=0;38;2;${hexToDecimal green ";"}
                *.arj=4;38;2;${hexToDecimal sapphire ";"}
                *.as=0;38;2;${hexToDecimal green ";"}
                *.asa=0;38;2;${hexToDecimal green ";"}
                *.aux=0;38;2;${hexToDecimal surface2 ";"}
                *.avi=0;38;2;${hexToDecimal flamingo ";"}
                *.awk=0;38;2;${hexToDecimal green ";"}
                *.bag=4;38;2;${hexToDecimal sapphire ";"}
                *.bak=0;38;2;${hexToDecimal surface2 ";"}
                *.bash=0;38;2;${hexToDecimal green ";"}
                *.bat=1;38;2;${hexToDecimal red ";"}
                *.bbl=0;38;2;${hexToDecimal surface2 ";"}
                *.bc=0;38;2;${hexToDecimal surface2 ";"}
                *.bcf=0;38;2;${hexToDecimal surface2 ";"}
                *.bib=0;38;2;${hexToDecimal yellow ";"}
                *.bin=4;38;2;${hexToDecimal sapphire ";"}
                *.blg=0;38;2;${hexToDecimal surface2 ";"}
                *.bmp=0;38;2;${hexToDecimal flamingo ";"}
                *.bsh=0;38;2;${hexToDecimal green ";"}
                *.bst=0;38;2;${hexToDecimal yellow ";"}
                *.bz2=4;38;2;${hexToDecimal sapphire ";"}
                *.bz=4;38;2;${hexToDecimal sapphire ";"}
                *.c++=0;38;2;${hexToDecimal green ";"}
                *.c=0;38;2;${hexToDecimal green ";"}
                *.cabal=0;38;2;${hexToDecimal green ";"}
                *.cache=0;38;2;${hexToDecimal surface2 ";"}
                *.cc=0;38;2;${hexToDecimal green ";"}
                *.cfg=0;38;2;${hexToDecimal yellow ";"}
                *.cgi=0;38;2;${hexToDecimal green ";"}
                *.clang-format=0;38;2;${hexToDecimal teal ";"}
                *.class=0;38;2;${hexToDecimal surface2 ";"}
                *.clj=0;38;2;${hexToDecimal green ";"}
                *.cmake.in=0;38;2;${hexToDecimal teal ";"}
                *.cmake=0;38;2;${hexToDecimal teal ";"}
                *.com=1;38;2;${hexToDecimal red ";"}
                *.conf=0;38;2;${hexToDecimal yellow ";"}
                *.config=0;38;2;${hexToDecimal yellow ";"}
                *.cp=0;38;2;${hexToDecimal green ";"}
                *.cpp=0;38;2;${hexToDecimal green ";"}
                *.cr=0;38;2;${hexToDecimal green ";"}
                *.crt=4;38;2;${hexToDecimal green ";"}
                *.cs=0;38;2;${hexToDecimal green ";"}
                *.css=0;38;2;${hexToDecimal green ";"}
                *.csv=0;38;2;${hexToDecimal yellow ";"}
                *.csx=0;38;2;${hexToDecimal green ";"}
                *.cxx=0;38;2;${hexToDecimal green ";"}
                *.d=0;38;2;${hexToDecimal green ";"}
                *.dart=0;38;2;${hexToDecimal green ";"}
                *.deb=4;38;2;${hexToDecimal sapphire ";"}
                *.def=0;38;2;${hexToDecimal green ";"}
                *.desktop=0;38;2;${hexToDecimal yellow ";"}
                *.di=0;38;2;${hexToDecimal green ";"}
                *.diff=0;38;2;${hexToDecimal green ";"}
                *.dll=1;38;2;${hexToDecimal red ";"}
                *.dmg=4;38;2;${hexToDecimal sapphire ";"}
                *.doc=0;38;2;${hexToDecimal red ";"}
                *.docx=0;38;2;${hexToDecimal red ";"}
                *.dot=0;38;2;${hexToDecimal green ";"}
                *.dox=0;38;2;${hexToDecimal teal ";"}
                *.dpr=0;38;2;${hexToDecimal green ";"}
                *.dyn_hi=0;38;2;${hexToDecimal surface2 ";"}
                *.dyn_o=0;38;2;${hexToDecimal surface2 ";"}
                *.el=0;38;2;${hexToDecimal green ";"}
                *.elc=0;38;2;${hexToDecimal green ";"}
                *.elm=0;38;2;${hexToDecimal green ";"}
                *.epp=0;38;2;${hexToDecimal green ";"}
                *.eps=0;38;2;${hexToDecimal flamingo ";"}
                *.epub=0;38;2;${hexToDecimal red ";"}
                *.erl=0;38;2;${hexToDecimal green ";"}
                *.ex=0;38;2;${hexToDecimal green ";"}
                *.exe=1;38;2;${hexToDecimal red ";"}
                *.exs=0;38;2;${hexToDecimal green ";"}
                *.fdb_latexmk=0;38;2;${hexToDecimal surface2 ";"}
                *.fdignore=0;38;2;${hexToDecimal teal ";"}
                *.fish=0;38;2;${hexToDecimal green ";"}
                *.flac=0;38;2;${hexToDecimal flamingo ";"}
                *.flake8=0;38;2;${hexToDecimal teal ";"}
                *.fls=0;38;2;${hexToDecimal surface2 ";"}
                *.flv=0;38;2;${hexToDecimal flamingo ";"}
                *.fnt=0;38;2;${hexToDecimal flamingo ";"}
                *.fon=0;38;2;${hexToDecimal flamingo ";"}
                *.fs=0;38;2;${hexToDecimal green ";"}
                *.fsi=0;38;2;${hexToDecimal green ";"}
                *.fsx=0;38;2;${hexToDecimal green ";"}
                *.gemspec=0;38;2;${hexToDecimal teal ";"}
                *.gif=0;38;2;${hexToDecimal flamingo ";"}
                *.git=0;38;2;${hexToDecimal surface2 ";"}
                *.gitattributes=0;38;2;${hexToDecimal teal ";"}
                *.gitconfig=0;38;2;${hexToDecimal teal ";"}
                *.gitignore=0;38;2;${hexToDecimal teal ";"}
                *.gitlab-ci.yml=0;38;2;${hexToDecimal green ";"}
                *.gitmodules=0;38;2;${hexToDecimal teal ";"}
                *.go=0;38;2;${hexToDecimal green ";"}
                *.gradle=0;38;2;${hexToDecimal green ";"}
                *.groovy=0;38;2;${hexToDecimal green ";"}
                *.gv=0;38;2;${hexToDecimal green ";"}
                *.gvy=0;38;2;${hexToDecimal green ";"}
                *.gz=4;38;2;${hexToDecimal sapphire ";"}
                *.h++=0;38;2;${hexToDecimal green ";"}
                *.h264=0;38;2;${hexToDecimal flamingo ";"}
                *.h=0;38;2;${hexToDecimal green ";"}
                *.hgrc=0;38;2;${hexToDecimal teal ";"}
                *.hh=0;38;2;${hexToDecimal green ";"}
                *.hi=0;38;2;${hexToDecimal surface2 ";"}
                *.hpp=0;38;2;${hexToDecimal green ";"}
                *.hs=0;38;2;${hexToDecimal green ";"}
                *.htc=0;38;2;${hexToDecimal green ";"}
                *.htm=0;38;2;${hexToDecimal yellow ";"}
                *.html=0;38;2;${hexToDecimal yellow ";"}
                *.hxx=0;38;2;${hexToDecimal green ";"}
                *.ico=0;38;2;${hexToDecimal flamingo ";"}
                *.ics=0;38;2;${hexToDecimal red ";"}
                *.idx=0;38;2;${hexToDecimal surface2 ";"}
                *.ignore=0;38;2;${hexToDecimal teal ";"}
                *.ilg=0;38;2;${hexToDecimal surface2 ";"}
                *.img=4;38;2;${hexToDecimal sapphire ";"}
                *.inc=0;38;2;${hexToDecimal green ";"}
                *.ind=0;38;2;${hexToDecimal surface2 ";"}
                *.ini=0;38;2;${hexToDecimal yellow ";"}
                *.inl=0;38;2;${hexToDecimal green ";"}
                *.ipp=0;38;2;${hexToDecimal green ";"}
                *.ipynb=0;38;2;${hexToDecimal green ";"}
                *.iso=4;38;2;${hexToDecimal sapphire ";"}
                *.jar=4;38;2;${hexToDecimal maroon ";"}
                *.java=0;38;2;${hexToDecimal green ";"}
                *.jl=0;38;2;${hexToDecimal green ";"}
                *.jpeg=0;38;2;${hexToDecimal flamingo ";"}
                *.jpg=0;38;2;${hexToDecimal flamingo ";"}
                *.js=0;38;2;${hexToDecimal green ";"}
                *.json=0;38;2;${hexToDecimal yellow ";"}
                *.kdbx=4;38;2;${hexToDecimal green ";"}
                *.kdevelop=0;38;2;${hexToDecimal teal ";"}
                *.kex=0;38;2;${hexToDecimal red ";"}
                *.key=4;38;2;${hexToDecimal green ";"}
                *.ko=1;38;2;${hexToDecimal red ";"}
                *.kt=0;38;2;${hexToDecimal green ";"}
                *.kts=0;38;2;${hexToDecimal green ";"}
                *.la=0;38;2;${hexToDecimal surface2 ";"}
                *.less=0;38;2;${hexToDecimal green ";"}
                *.lisp=0;38;2;${hexToDecimal green ";"}
                *.ll=0;38;2;${hexToDecimal green ";"}
                *.lo=0;38;2;${hexToDecimal surface2 ";"}
                *.localized=0;38;2;${hexToDecimal surface2 ";"}
                *.lock=0;38;2;${hexToDecimal overlay1 ";"}
                *.log=0;38;2;${hexToDecimal surface2 ";"}
                *.ltx=0;38;2;${hexToDecimal green ";"}
                *.lua=0;38;2;${hexToDecimal sapphire ";"}
                *.m3u=0;38;2;${hexToDecimal flamingo ";"}
                *.m4a=0;38;2;${hexToDecimal flamingo ";"}
                *.m4v=0;38;2;${hexToDecimal flamingo ";"}
                *.m=0;38;2;${hexToDecimal green ";"}
                *.make=0;38;2;${hexToDecimal teal ";"}
                *.markdown=0;38;2;${hexToDecimal yellow ";"}
                *.matlab=0;38;2;${hexToDecimal green ";"}
                *.mca=0;38;2;${hexToDecimal green ";"}
                *.md=0;38;2;${hexToDecimal yellow ";"}
                *.mdown=0;38;2;${hexToDecimal yellow ";"}
                *.mid=0;38;2;${hexToDecimal flamingo ";"}
                *.mir=0;38;2;${hexToDecimal green ";"}
                *.mkv=0;38;2;${hexToDecimal flamingo ";"}
                *.ml=0;38;2;${hexToDecimal green ";"}
                *.mli=0;38;2;${hexToDecimal green ";"}
                *.mn=0;38;2;${hexToDecimal green ";"}
                *.mov=0;38;2;${hexToDecimal flamingo ";"}
                *.mp3=0;38;2;${hexToDecimal flamingo ";"}
                *.mp4=0;38;2;${hexToDecimal flamingo ";"}
                *.mpeg=0;38;2;${hexToDecimal flamingo ";"}
                *.mpg=0;38;2;${hexToDecimal flamingo ";"}
                *.nb=0;38;2;${hexToDecimal green ";"}
                *.nix=0;38;2;${hexToDecimal sky ";"}
                *.o=0;38;2;${hexToDecimal surface2 ";"}
                *.odp=0;38;2;${hexToDecimal red ";"}
                *.ods=0;38;2;${hexToDecimal red ";"}
                *.odt=0;38;2;${hexToDecimal red ";"}
                *.ogg=0;38;2;${hexToDecimal flamingo ";"}
                *.opus=0;38;2;${hexToDecimal flamingo ";"}
                *.org=0;38;2;${hexToDecimal yellow ";"}
                *.orig=0;38;2;${hexToDecimal surface2 ";"}
                *.otf=0;38;2;${hexToDecimal flamingo ";"}
                *.out=0;38;2;${hexToDecimal surface2 ";"}
                *.p=0;38;2;${hexToDecimal green ";"}
                *.pas=0;38;2;${hexToDecimal green ";"}
                *.patch=0;38;2;${hexToDecimal green ";"}
                *.pbm=0;38;2;${hexToDecimal flamingo ";"}
                *.pdf=0;38;2;${hexToDecimal red ";"}
                *.pgm=0;38;2;${hexToDecimal flamingo ";"}
                *.php=0;38;2;${hexToDecimal green ";"}
                *.pid=0;38;2;${hexToDecimal surface2 ";"}
                *.pkg=4;38;2;${hexToDecimal sapphire ";"}
                *.pl=0;38;2;${hexToDecimal green ";"}
                *.pm=0;38;2;${hexToDecimal green ";"}
                *.png=0;38;2;${hexToDecimal flamingo ";"}
                *.pod=0;38;2;${hexToDecimal green ";"}
                *.pp=0;38;2;${hexToDecimal green ";"}
                *.ppm=0;38;2;${hexToDecimal flamingo ";"}
                *.pps=0;38;2;${hexToDecimal red ";"}
                *.ppt=0;38;2;${hexToDecimal red ";"}
                *.pptx=0;38;2;${hexToDecimal red ";"}
                *.pro=0;38;2;${hexToDecimal teal ";"}
                *.ps1=0;38;2;${hexToDecimal green ";"}
                *.ps=0;38;2;${hexToDecimal red ";"}
                *.psd1=0;38;2;${hexToDecimal green ";"}
                *.psd=0;38;2;${hexToDecimal flamingo ";"}
                *.psm1=0;38;2;${hexToDecimal green ";"}
                *.purs=0;38;2;${hexToDecimal green ";"}
                *.py=0;38;2;${hexToDecimal green ";"}
                *.pyc=0;38;2;${hexToDecimal surface2 ";"}
                *.pyd=0;38;2;${hexToDecimal surface2 ";"}
                *.pyo=0;38;2;${hexToDecimal surface2 ";"}
                *.r=0;38;2;${hexToDecimal green ";"}
                *.rar=4;38;2;${hexToDecimal sapphire ";"}
                *.rb=0;38;2;${hexToDecimal green ";"}
                *.rgignore=0;38;2;${hexToDecimal teal ";"}
                *.rlib=0;38;2;${hexToDecimal surface2 ";"}
                *.rm=0;38;2;${hexToDecimal flamingo ";"}
                *.rpm=4;38;2;${hexToDecimal sapphire ";"}
                *.rs=0;38;2;${hexToDecimal peach ";"}
                *.rst=0;38;2;${hexToDecimal yellow ";"}
                *.rtf=0;38;2;${hexToDecimal red ";"}
                *.sass=0;38;2;${hexToDecimal green ";"}
                *.sbt=0;38;2;${hexToDecimal green ";"}
                *.scala=0;38;2;${hexToDecimal green ";"}
                *.scons_opt=0;38;2;${hexToDecimal surface2 ";"}
                *.sconsign.dblite=0;38;2;${hexToDecimal surface2 ";"}
                *.scss=0;38;2;${hexToDecimal green ";"}
                *.sh=0;38;2;${hexToDecimal green ";"}
                *.shtml=0;38;2;${hexToDecimal yellow ";"}
                *.so=1;38;2;${hexToDecimal red ";"}
                *.sql=0;38;2;${hexToDecimal green ";"}
                *.sty=0;38;2;${hexToDecimal surface2 ";"}
                *.svg=0;38;2;${hexToDecimal flamingo ";"}
                *.swf=0;38;2;${hexToDecimal flamingo ";"}
                *.swift=0;38;2;${hexToDecimal green ";"}
                *.swp=0;38;2;${hexToDecimal surface2 ";"}
                *.sxi=0;38;2;${hexToDecimal red ";"}
                *.sxw=0;38;2;${hexToDecimal red ";"}
                *.synctex.gz=0;38;2;${hexToDecimal surface2 ";"}
                *.t=0;38;2;${hexToDecimal green ";"}
                *.tar=4;38;2;${hexToDecimal sapphire ";"}
                *.tbz2=4;38;2;${hexToDecimal sapphire ";"}
                *.tbz=4;38;2;${hexToDecimal sapphire ";"}
                *.tcl=0;38;2;${hexToDecimal green ";"}
                *.td=0;38;2;${hexToDecimal green ";"}
                *.tex=0;38;2;${hexToDecimal green ";"}
                *.tgz=4;38;2;${hexToDecimal sapphire ";"}
                *.tif=0;38;2;${hexToDecimal flamingo ";"}
                *.tiff=0;38;2;${hexToDecimal flamingo ";"}
                *.tml=0;38;2;${hexToDecimal yellow ";"}
                *.tmp=0;38;2;${hexToDecimal surface2 ";"}
                *.toast=4;38;2;${hexToDecimal sapphire ";"}
                *.toc=0;38;2;${hexToDecimal surface2 ";"}
                *.toml=0;38;2;${hexToDecimal yellow ";"}
                *.travis.yml=0;38;2;${hexToDecimal green ";"}
                *.ts=0;38;2;${hexToDecimal green ";"}
                *.tsx=0;38;2;${hexToDecimal green ";"}
                *.ttf=0;38;2;${hexToDecimal flamingo ";"}
                *.txt=0;38;2;${hexToDecimal yellow ";"}
                *.ui=0;38;2;${hexToDecimal yellow ";"}
                *.vb=0;38;2;${hexToDecimal green ";"}
                *.vcd=4;38;2;${hexToDecimal sapphire ";"}
                *.vim=0;38;2;${hexToDecimal green ";"}
                *.vob=0;38;2;${hexToDecimal flamingo ";"}
                *.wav=0;38;2;${hexToDecimal flamingo ";"}
                *.webm=0;38;2;${hexToDecimal flamingo ";"}
                *.webp=0;38;2;${hexToDecimal flamingo ";"}
                *.wma=0;38;2;${hexToDecimal flamingo ";"}
                *.wmv=0;38;2;${hexToDecimal flamingo ";"}
                *.woff=0;38;2;${hexToDecimal flamingo ";"}
                *.wv=0;38;2;${hexToDecimal flamingo ";"}
                *.xbps=4;38;2;${hexToDecimal sapphire ";"}
                *.xcf=0;38;2;${hexToDecimal flamingo ";"}
                *.xhtml=0;38;2;${hexToDecimal yellow ";"}
                *.xlr=0;38;2;${hexToDecimal red ";"}
                *.xls=0;38;2;${hexToDecimal red ";"}
                *.xlsx=0;38;2;${hexToDecimal red ";"}
                *.xml=0;38;2;${hexToDecimal yellow ";"}
                *.xmp=0;38;2;${hexToDecimal yellow ";"}
                *.xz=4;38;2;${hexToDecimal sapphire ";"}
                *.yaml=0;38;2;${hexToDecimal yellow ";"}
                *.yml=0;38;2;${hexToDecimal yellow ";"}
                *.z=4;38;2;${hexToDecimal sapphire ";"}
                *.zip=4;38;2;${hexToDecimal sapphire ";"}
                *.zsh=0;38;2;${hexToDecimal green ";"}
                *.zst=4;38;2;${hexToDecimal sapphire ";"}
                *CMakeCache.txt=0;38;2;${hexToDecimal surface2 ";"}
                *CMakeLists.txt=0;38;2;${hexToDecimal teal ";"}
                *CODEOWNERS=0;38;2;${hexToDecimal teal ";"}
                *CONTRIBUTORS.md=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *CONTRIBUTORS.txt=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *CONTRIBUTORS=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *COPYING=0;38;2;${hexToDecimal overlay1 ";"}
                *COPYRIGHT=0;38;2;${hexToDecimal overlay1 ";"}
                *Dockerfile=0;38;2;${hexToDecimal sky ";"}
                *Doxyfile=0;38;2;${hexToDecimal teal ";"}
                *INSTALL.md=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *INSTALL.txt=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *INSTALL=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *LICENSE-APACHE=0;38;2;${hexToDecimal overlay1 ";"}
                *LICENSE-MIT=0;38;2;${hexToDecimal overlay1 ";"}
                *LICENSE=0;38;2;${hexToDecimal overlay1 ";"}
                *MANIFEST.in=0;38;2;${hexToDecimal teal ";"}
                *Makefile.am=0;38;2;${hexToDecimal teal ";"}
                *Makefile.in=0;38;2;${hexToDecimal surface2 ";"}
                *Makefile=0;38;2;${hexToDecimal teal ";"}
                *README.md=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *README.txt=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *README=0;38;2;${hexToDecimal base ";"};48;2;${hexToDecimal yellow ";"}
                *SConscript=0;38;2;${hexToDecimal teal ";"}
                *SConstruct=0;38;2;${hexToDecimal teal ";"}
                *TODO.md=1
                *TODO.txt=1
                *TODO=1
                *appveyor.yml=0;38;2;${hexToDecimal green ";"}
                *configure.ac=0;38;2;${hexToDecimal teal ";"}
                *configure=0;38;2;${hexToDecimal teal ";"}
                *docker-compose.yml=0;38;2;${hexToDecimal sky ";"}
                *hgrc=0;38;2;${hexToDecimal teal ";"}
                *package-lock.json=0;38;2;${hexToDecimal surface2 ";"}
                *passwd=0;38;2;${hexToDecimal yellow ";"}
                *requirements.txt=0;38;2;${hexToDecimal teal ";"}
                *setup.py=0;38;2;${hexToDecimal teal ";"}
                *shadow=0;38;2;${hexToDecimal yellow ";"}
            '';
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
