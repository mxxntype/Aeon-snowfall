# INFO: Command line CSV viewer.
#
# https://github.com/YS-L/csvlens

{
    inputs,
    pkgs,
    ...
}:

(pkgs.callPackage inputs.naersk {}).buildPackage {
    src = "${inputs.csvlens}";

    # NOTE: If your application uses OpenSSL (making the build process fail), try:
    # nativeBuildInputs = with pkgs; [ pkg-config ];
    # buildInputs = with pkgs; [ openssl ];
}
