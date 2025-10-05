# INFO: Recolor images to a certain palette.
#
# https://github.com/ziap/repalette

{ pkgs, stdenv, fetchurl, ... }: let

stb_image_h = fetchurl {
    url = "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h";
    sha256 = "1cq089gygwzcbg4nm4cxh75fyv9nk27yrynvh91qnj29bpijyk2r";
};
stb_image_write_h = fetchurl {
    url = "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h";
    sha256 = "01aaj6v3q19jiqdcywr4q7r3901ksahm8qxkzy54dx4wganz1mfb";
};

in stdenv.mkDerivation {
    pname = "repalette";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
        owner = "ziap";
        repo = "repalette";
        rev = "f101bd93d94664fde88a3f5c36eecf2d5d13eaf7";
        hash = "sha256-KgL1U0PCGb1fvYDXzggOkRWQguBg5+P2EgGakrhvl9M=";
    };

    buildPhase = ''
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
