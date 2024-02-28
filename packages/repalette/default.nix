# INFO: Recolor images to a certain palette.
#
# https://github.com/ziap/repalette

{
    inputs,
    pkgs,
    stdenv,
    fetchurl,
    ...
}:

let
    # NOTE: Makefile tries to download these with `curl`, which fails.
    stb_image_h = fetchurl {
        url = "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h";
        sha256 = "0p6x42dnf22djz0p6jw9gviy1qs2ljpj7v72flng78g6i6k1ajy5";
    };
    stb_image_write_h = fetchurl {
        url = "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h";
        sha256 = "01aaj6v3q19jiqdcywr4q7r3901ksahm8qxkzy54dx4wganz1mfb";
    };
in

stdenv.mkDerivation {
    pname = "repalette";
    version = "1.0.0";
    src = inputs.repalette;

    buildPhase = /* bash */ ''
        cp ${stb_image_h} ./stb_image.h
        cp ${stb_image_write_h} ./stb_image_write.h
        make repalette
    '';

    installPhase = ''
        mkdir -p $out/bin
        cp repalette $out/bin
    '';

    nativeBuildInputs = [ ];
    buildInputs = with pkgs; [ clang ];
}
