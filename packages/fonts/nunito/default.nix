{ lib, stdenvNoCC, fetchgit, ... }:

stdenvNoCC.mkDerivation {
    pname = "nunito";
    version = "1.0.0";

    src = fetchgit {
        url = "https://github.com/googlefonts/nunito";
        rev = "8c6a9bb9732545b9ed53f29ec5e1ab0ff53c4e6f";
        sha256 = "sha256-9Ap+WaUd5chxS4cJbT86aTopKOvNpNsFawnx1h5HwDw=";
        sparseCheckout = [ "fonts/variable" ];
    };

    installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp -R $src/fonts/variable/*.ttf $out/share/fonts/truetype/
    '';

    meta = with lib; {
        description = "Nunito font family from Google Fonts";
        homepage = "https://fonts.google.com/specimen/Nunito";
        platforms = platforms.all;
    };
}
