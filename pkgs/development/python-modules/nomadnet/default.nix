{ lib
, buildPythonPackage
, rns
, fetchFromGitHub
, lxmf
, urwid
, pythonOlder
, qrcode
}:

buildPythonPackage rec {
  pname = "nomadnet";
  version = "0.3.1";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = "NomadNet";
    rev = "refs/tags/${version}";
    hash = "sha256-bpMv7dFX6hQoR8uG8IRy8JaDGLlU50hOPAI6jWmlMWI=";
  };

  propagatedBuildInputs = [
    rns
    lxmf
    urwid
    qrcode
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [
    "nomadnet"
  ];

  meta = with lib; {
    description = "Off-grid, resilient mesh communication";
    homepage = "https://github.com/markqvist/NomadNet";
    changelog = "https://github.com/markqvist/NomadNet/releases/tag/${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fab ];
  };
}
