# NOTE: Some info about wrapping AppImages can be found here:
# https://aux-docs.pyrox.pages.gay/Nixpkgs/Build-Helpers/images/appimagetools.section

{ pkgs, ... }: let

job-id = "11864261921";

in pkgs.appimageTools.wrapType2 {
    pname = "openrgb";
    version = "git-${job-id}";
    src = pkgs.fetchurl {
        url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/jobs/${job-id}/artifacts/raw/OpenRGB-x86_64.AppImage";
        hash = "sha256-iDCDfJA5kRzroFhJg3tjKdwn6E2aVMbEIifJM9/NuZk=";
    };
}
