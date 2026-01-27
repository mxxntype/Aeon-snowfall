# NOTE: Some info about wrapping AppImages can be found here:
# https://aux-docs.pyrox.pages.gay/Nixpkgs/Build-Helpers/images/appimagetools.section

{ pkgs, ... }: let

job-id = "12875428990";

in pkgs.appimageTools.wrapType2 {
    pname = "openrgb";
    version = "git-${job-id}";
    src = pkgs.fetchurl {
        url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/jobs/${job-id}/artifacts/raw/OpenRGB-x86_64.AppImage";
        hash = "sha256-U6eTZ6Ynp0OiZuoRaZdUozPlokJYinTjTVlVp+3+M+o=";
    };
}
