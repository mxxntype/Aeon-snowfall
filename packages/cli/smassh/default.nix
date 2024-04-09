{
    pkgs,
    ...
}:

with pkgs;
with pkgs.python311Packages;

buildPythonPackage rec {
    pname = "smassh";
    version = "3.1.0";
    format = "pyproject";

    src = fetchPypi {
        inherit pname version;
        sha256 = "9JN97RrHPL1n5ziIwJNiATK9Yo8EwnypjSt4D5SRI7E=";
    };

    propagatedBuildInputs = [
        poetry-core
        click
        appdirs
        rich
        requests
        textual
    ];
}
