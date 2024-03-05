{
    pkgs,
    ...
}:

with pkgs;
with pkgs.python311Packages;

buildPythonPackage rec {
    pname = "magika";
    version = "0.5.0";
    format = "pyproject";

    src = fetchPypi {
        inherit pname version;
        sha256 = "r6C7iDCG/o3JEvweQGb4upr+LuHvmNtkwtduZGehCsc=";
    };

    propagatedBuildInputs = [
        setuptools
        poetry-core
        python-dotenv
        numpy
        onnxruntime
        tqdm
        tabulate
    ];
}
