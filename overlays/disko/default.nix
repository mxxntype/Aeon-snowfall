# NOTE: Disko overlay.

{
    disko,
    ...
}:

_final: prev: {
    inherit (disko.packages.${prev.stdenv.hostPlatform.system})
        disko
        disko-doc
        ;
}
