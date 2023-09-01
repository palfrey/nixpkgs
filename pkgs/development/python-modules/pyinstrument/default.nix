{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "pyinstrument";
  version = "4.5.2";

  src = fetchFromGitHub {
    owner = "joerick";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-VL/JzgMxn5zABfmol+5oofR1RjyxTdzvUi6JnwsSFao=";
  };

  # Module import recursion
  doCheck = false;

  pythonImportsCheck = [
    "pyinstrument"
  ];

  meta = with lib; {
    description = "Call stack profiler for Python";
    homepage = "https://github.com/joerick/pyinstrument";
    license = licenses.bsd3;
    maintainers = with maintainers; [ onny ];
  };
}
