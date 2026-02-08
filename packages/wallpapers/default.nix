{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
    name = "vyrx-dev-wallpapers";

    src = pkgs.fetchFromGitHub {
        owner = "vyrx-dev";
        repo = "Wallpapers";
        rev = "6922e4d57fd210dedffb54b75c6a6c3eaba76221";
        hash = "sha256-SDH2+dfjhPXoXQZUIsOwP5U63IH6mtbXE5zYp6EJM+U=";
    };

    buildCommand = /* bash */ ''
        mkdir $out

        cp -rv $src/calm       $out/
        cp -rv $src/digital    $out/
        cp -rv $src/gruvbox    $out/
        cp -rv $src/monochrome $out/
        cp -rv $src/nord       $out/
        cp -rv $src/others     $out/
    '';
}
