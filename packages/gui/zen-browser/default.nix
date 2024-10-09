{
    inputs,
    pkgs,
    ...
}:

pkgs.appimageTools.wrapType2 {
    name = "zen";
    src = inputs.zen-browser-appimage;
}
