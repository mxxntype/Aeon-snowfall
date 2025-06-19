{
    inputs,
    pkgs,
    ...
}:

pkgs.appimageTools.wrapType2 {
    pname = "zen-browser";
    version = "appimage";
    src = inputs.zen-browser-appimage;
}
