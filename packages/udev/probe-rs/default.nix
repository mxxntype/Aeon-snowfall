{ pkgs, ...}:

pkgs.stdenvNoCC.mkDerivation {
    name = "probe-rs-rules";
    src = ./.;
    installPhase = ''
        mkdir -p $out/lib/udev/rules.d
        cp 69-probe-rs.rules $out/lib/udev/rules.d/
    '';
}
