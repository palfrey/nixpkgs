{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  isodate,
  typing-extensions,
  yarl,
}:

buildPythonPackage rec {
  pname = "azure-data-tables";
  version = "12.6.0";
  pyproject = true;

  src = fetchPypi {
    pname = "azure_data_tables";
    inherit version;
    hash = "sha256-4NVZgROFX5EU/XZxYj01UJ+Ddylwz9xZeQGzX0LcMTQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
    yarl
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [ "azure.data.tables" ];

  meta = with lib; {
    description = "NoSQL data storage service that can be accessed from anywhere";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-data-tables_${version}/sdk/tables/azure-data-tables/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
  };
}
