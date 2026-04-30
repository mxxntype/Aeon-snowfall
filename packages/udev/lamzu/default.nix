{ pkgs, ...}:

pkgs.stdenvNoCC.mkDerivation {
    name = "lamzu-rules";
    src = ./.;
    installPhase = ''
        mkdir -p $out/lib/udev/rules.d
        cp 69-lamzu.rules $out/lib/udev/rules.d/
    '';
}
