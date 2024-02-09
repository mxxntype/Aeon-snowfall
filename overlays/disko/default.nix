# NOTE: Disko overlay.

{
    disko,
    ...
}:

final: prev: {
    inherit (disko.packages.${prev.system})
        disko
        disko-doc
        ;
}
