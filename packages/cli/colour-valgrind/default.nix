{ pkgs, ... }:

with pkgs;
with pkgs.python311Packages;

buildPythonPackage rec {
    pname = "colour-valgrind";
    version = "0.3.9";
    format = "pyproject";

    src = fetchPypi {
        inherit pname version;
        sha256 = "NKfZLjyCpj2AZEpXHT345NKd17FLJj3ukDB9XWQyYZ0=";
    };

    propagatedBuildInputs = [
        regex
        setuptools
        six
        colorama
    ];
}
