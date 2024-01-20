{
    inputs,
    pkgs,
    ...
}:

(pkgs.callPackage inputs.naersk {}).buildPackage {
    src = ../..;

    # NOTE: If your application uses OpenSSL (making the build process fail), try:
    # nativeBuildInputs = with pkgs; [ pkg-config ];
    # buildInputs = with pkgs; [ openssl ];
}
