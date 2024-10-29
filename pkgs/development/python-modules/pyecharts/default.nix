{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  jinja2,
  numpy,
  pandas,
  pillow,
  prettytable,
  pytestCheckHook,
  pythonOlder,
  requests,
  setuptools,
  simplejson,
}:

buildPythonPackage rec {
  pname = "pyecharts";
  version = "2.0.6";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "pyecharts";
    repo = "pyecharts";
    rev = "refs/tags/v${version}";
    hash = "sha256-cD2jtiE2LDKCmhqM+qKYcsZyjDyMDpp8/Bn17csZgqo=";
  };

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    prettytable
    simplejson
  ];

  optional-dependencies = {
    images = [ pillow ];
  };

  nativeCheckInputs = [
    numpy
    pandas
    pytestCheckHook
    requests
  ] ++ lib.flatten (builtins.attrValues optional-dependencies);

  pythonImportsCheck = [ "pyecharts" ];

  disabledTests = [
    # Tests require network access
    "test_render_embed_js"
    "test_display_javascript_v2"
    "test_lines3d_base"
  ];

  meta = {
    description = "Python Echarts Plotting Library";
    homepage = "https://github.com/pyecharts/pyecharts";
    changelog = "https://github.com/pyecharts/pyecharts/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
