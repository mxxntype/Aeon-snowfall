# INFO: JFScan - Just Fu*king Scan.
# JFScan is a wrapper that leverages the speed of Masscan and Nmap's fingerprinting capabilities.
# SOURCE: https://github.com/nullt3r/jfscan

{
    inputs,
    pkgs,
    ...
}:

with pkgs;
with pkgs.python3Packages;

buildPythonPackage {
    pname = "jfscan";
    version = "1.6.2";
    src = inputs.jfscan;
    propagatedBuildInputs = [
        setuptools
        dnspython
        validators
        masscan
    ];
}
