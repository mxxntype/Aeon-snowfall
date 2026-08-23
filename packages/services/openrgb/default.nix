# NOTE: Some info about wrapping AppImages can be found here:
# https://aux-docs.pyrox.pages.gay/Nixpkgs/Build-Helpers/images/appimagetools.section

{ pkgs, ... }: let

job-id = "16023084740";

in pkgs.appimageTools.wrapType2 {
    pname = "openrgb";
    version = "git-${job-id}";
    src = pkgs.fetchurl {
        url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/jobs/${job-id}/artifacts/raw/OpenRGB-x86_64.AppImage";
        hash = "sha256-6mWMB1/v2dXD/a6Nt14h6CcvGbTpEeP/SziC5C/UyXs=";
    };
}
