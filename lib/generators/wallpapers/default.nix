{ ... }:

{
    fromNamecard = {
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
        name = "gegl-pipeline";
        src = source-image;

        nativeBuildInputs = with pkgs; [ gegl.dev imagemagick ];
        buildCommand = let dither-levels-str = toString dither-levels;
        in /* bash */ ''
            mkdir $out
            magick $src input.png # Ensure GEGL gets a well-formed PNG as input.

            gegl input.png -o namecard.png -- \
                scale-size-keepaspect sampler=nearest y=${toString pixelation-y} \
                wind direction=bottom threshold=8 strength=1 \
                scale-size-keepaspect sampler=nearest y=${toString dither-y} \
                dither dither-method=bayer red-levels=${dither-levels-str} green-levels=${dither-levels-str} blue-levels=${dither-levels-str} \
                scale-size-keepaspect sampler=nearest y=${toString namecard-dimensions.y}

            gegl -o namecard-bordered-inner.png -- \
                rectangle \
                    color=#${border-colors.inner} x=0 y=0 \
                    width=${toString (namecard-dimensions.x + border-thickness * 2)} \
                    height=${toString (namecard-dimensions.y + border-thickness * 2)} \
                over aux=[load path=namecard.png translate sampler=nearest x=${toString border-thickness} y=${toString border-thickness}]

            gegl -o namecard-bordered-outer.png -- \
                rectangle \
                    color=#${border-colors.outer} x=0 y=0 \
                    width=${toString (namecard-dimensions.x + border-thickness * 4)} \
                    height=${toString (namecard-dimensions.y + border-thickness * 4)} \
                over aux=[load path=namecard-bordered-inner.png translate sampler=nearest x=${toString border-thickness} y=${toString border-thickness}]

            # HACK: Dude, I can't really dunk on GEGL because it kinda inspired this whole thing,
            # but WHAT THE ACTUAL LIVING FUCK IS WRONG WITH LINEAR GRADIENTS AND INFINITE LOOPS ALL OVER THE PLACE???
            # My brother is christ is 2025 and C software is still driving me up the fucking wall man
            magick -size 3840x2160 gradient:#${gradient-colors.start}-#${gradient-colors.end} background-gradient.png

            magick background-gradient.png namecard-bordered-outer.png -gravity center -composite $out/output.png
        '';
    };
}
