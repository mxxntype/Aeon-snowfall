# NOTE: Disko overlay.

{
    disko,
    ...
}:

_final: prev: {
    inherit (disko.packages.${prev.system})
        disko
        disko-doc
        ;
}
