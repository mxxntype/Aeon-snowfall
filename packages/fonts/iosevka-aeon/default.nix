{
    inputs,
    buildNpmPackage,
    nerd-font-patcher,
    ttfautohint,
    writeText,
    ...
}:

let
    font-name = "IosevkaAeon";
    build-plan = writeText "private-build-plans.toml" /* toml */ ''
        [buildPlans.${font-name}]
        family = "${font-name}"
        spacing = "term"
        serifs = "sans"
        noCvSs = false
        exportGlyphNames = true

          [buildPlans.${font-name}.variants]
          inherits = "ss07"

            [buildPlans.${font-name}.variants.design]
            six = "straight-bar"
            nine = "straight-bar"
            capital-a = "round-top-serifless"
            capital-x = "curly-serifless"
            i = "serifed-flat-tailed"
            j = "flat-hook-serifed"
            l = "serifed-flat-tailed"
            m = "earless-rounded-double-arch-serifless"
            n = "earless-corner-straight-serifless"
            p = "earless-rounded-serifless"
            r = "earless-corner-serifless"
            t = "flat-hook-short-neck"
            u = "toothless-corner-serifless"
            v = "curly-serifless"
            w = "rounded-vertical-sides-serifless"
            x = "curly-serifless"
            y = "cursive-serifless"
            z = "curly-serifless"
            cyrl-er = "earless-corner-serifless"
            asterisk = "hex-low"
            paren = "flat-arc"
            at = "threefold-solid-inner"
            micro-sign = "toothless-corner-serifless"
            lig-neq = "vertical-dotted"
            lig-double-arrow-bar = "without-notch"

        [buildPlans.${font-name}.weights.Regular]
        shape = 400
        menu = 400
        css = 400

        [buildPlans.${font-name}.weights.Medium]
        shape = 500
        menu = 500
        css = 500

        [buildPlans.${font-name}.weights.SemiBold]
        shape = 600
        menu = 600
        css = 600

        [buildPlans.${font-name}.weights.Bold]
        shape = 700
        menu = 700
        css = 700

        [buildPlans.${font-name}.widths.Normal]
        shape = 500
        menu = 5
        css = "normal"

        [buildPlans.${font-name}.slopes.Upright]
        angle = 0
        shape = "upright"
        menu = "upright"
        css = "normal"

        [buildPlans.${font-name}.slopes.Italic]
        angle = 9.4
        shape = "italic"
        menu = "italic"
        css = "italic"
    '';
in

buildNpmPackage {
    pname = "iosevka-aeon";
    version = "git";
    src = inputs.iosevka;
    npmDepsHash = "sha256-PYzNg5gduwtwc99GyatXnmHCh9mpAulz43Ehdle0rAM=";

    nativeBuildInputs = [
        nerd-font-patcher
        ttfautohint
    ];

    configurePhase = ''
        runHook preConfigure
        cp ${build-plan} ./private-build-plans.toml;
        runHook postConfigure
    '';

    buildPhase = ''
        export HOME=$TMPDIR
        runHook preBuild

        npm run build -- ttf::${font-name} --jCmd=$NIX_BUILD_CORES
        for ttf_file in dist/${font-name}/TTF/*.ttf; do
            nerd-font-patcher "$ttf_file" --complete
        done

        runHook postBuild
    '';

    installPhase = ''
        runHook preInstall
        mkdir -p $out/share/fonts/truetype
        install -Dm644 *.ttf -t $out/share/fonts/truetype
        runHook postInstall
    '';
}
