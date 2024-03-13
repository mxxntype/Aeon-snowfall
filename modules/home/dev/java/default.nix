# INFO: Java Home-manager module.

{
    config,
    lib,
    pkgs,
    ...
}:

with lib; {
    options.aeon.dev.java = {
        enable = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = let
        inherit (config.aeon.dev.java)
            enable
            ;
    in mkIf enable {
        home.packages = with pkgs; [
            gradle
            maven
            jdk
            google-java-format
            jdt-language-server
        ];

        # Environment variable specifying the plugin directory of the language server.
        home.sessionVariables.JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";
    };
}
