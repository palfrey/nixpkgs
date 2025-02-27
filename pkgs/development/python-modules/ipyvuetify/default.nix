{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Python Inputs
  setuptools,
  ipyvue,
}:

buildPythonPackage rec {
  pname = "ipyvuetify";
  version = "1.11.0";
  pyproject = true;

  # GitHub version tries to run npm (Node JS)
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-j3LUVLNaioVa4ul9RkRApt4oH8CFrObQLipDcfW7fkQ=";
  };

  # drop pynpm which tries to install node_modules
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"jupyterlab~=4.0",' "" \
      --replace-fail '"pynpm"' ""
  '';

  build-system = [ setuptools ];

  dependencies = [ ipyvue ];

  doCheck = false; # no tests on PyPi/GitHub
  pythonImportsCheck = [ "ipyvuetify" ];

  meta = with lib; {
    description = "Jupyter widgets based on Vuetify UI Components";
    homepage = "https://github.com/mariobuikhuizen/ipyvuetify";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
