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
        noCvSs = true
        exportGlyphNames = false

        [buildPlans.${font-name}.variants]
        inherits = "ss07"

        [buildPlans.${font-name}.ligations]
        inherits = "dlig"

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
    npmDepsHash = "sha256-lBLz/BsSVh6szJxunoTj31oxB/3yqd1oWjSzTmQFGv8=";

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