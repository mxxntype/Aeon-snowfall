_: {
    generators.wallpapers.fromNamecard = {
        name,
        pkgs,
        source-image,
        pixelation-y ? 80,
        dither-y ? pixelation-y * 2,
        dither-levels ? 12,
        namecard-dimensions ? { x = 1680; y = 800; },
        border-thickness ? 6,
        border-colors ? { inner = "000000"; outer = "444444"; },
        gradient-colors ? { start = "ff0000"; end = "0000ff"; },
    }: pkgs.stdenvNoCC.mkDerivation {
        name = "wp-namecard-${name}";
        src = source-image;

        nativeBuildInputs = with pkgs; [ gegl.dev imagemagick ];
        buildCommand = let dither-levels-str = toString dither-levels;
        in /* bash */ ''
            mkdir $out
            magick $src input.png

            # Pixelate & dither the namecard at various resolutions.
            gegl input.png -o namecard.png -- \
                scale-size-keepaspect sampler=nearest y=${toString pixelation-y} \
                wind direction=bottom threshold=8 strength=1 \
                scale-size-keepaspect sampler=nearest y=${toString dither-y} \
                dither dither-method=bayer \
                    red-levels=${dither-levels-str} \
                    green-levels=${dither-levels-str} \
                    blue-levels=${dither-levels-str} \
                scale-size-keepaspect sampler=nearest y=${toString namecard-dimensions.y}

            # Create the "inner" border around the namecard.
            gegl -o overlay.png -- \
                rectangle \
                    color=#${border-colors.inner} x=0 y=0 \
                    width=${toString (namecard-dimensions.x + border-thickness * 2)} \
                    height=${toString (namecard-dimensions.y + border-thickness * 2)} \
                over aux=[ \
                    load path=namecard.png \
                    translate sampler=nearest x=${toString border-thickness} y=${toString border-thickness}]

            # Create the "outer" border around the namecard.
            gegl -o overlay.png -- \
                rectangle \
                    color=#${border-colors.outer} x=0 y=0 \
                    width=${toString (namecard-dimensions.x + border-thickness * 4)} \
                    height=${toString (namecard-dimensions.y + border-thickness * 4)} \
                over aux=[ \
                    load path=overlay.png \
                    translate sampler=nearest x=${toString border-thickness} y=${toString border-thickness}]

            # Create the background gradient & dither it, then scale to the target resolution.
            # 
            # HACK: Dude, I can't really dunk on GEGL because it kinda inspired this whole thing,
            # but WHAT THE ACTUAL FUCK IS UP WITH GETTING STUCK IN AN INFINITE LOOP FOR NO REASON
            # Couldn't for the life of me figure out what arcane spell is required to make it work,
            # ImageMagick did the trick instead.
            # My brother in christ its 2025 and C software is still driving me up the fucking wall
            magick -size 768x432 gradient:#${gradient-colors.start}-#${gradient-colors.end} background.png
            gegl background.png -o background.png -- \
                dither dither-method=bayer \
                    red-levels=${toString (dither-levels * 3)} \
                    green-levels=${toString (dither-levels * 3)} \
                    blue-levels=${toString (dither-levels * 3)} \
                scale-size-keepaspect sampler=nearest x=3840

            # Render the bordered namecard in the center above the gradient.
            magick background.png overlay.png -gravity center -composite $out/output.png
        '';
    };
}
