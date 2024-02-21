{ lib
, buildPythonPackage
, fetchPypi
, azure-core
, pythonOlder
, typing-extensions
}:

buildPythonPackage rec {
  pname = "azure-eventhub";
  version = "5.11.6";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-89Q1o/cnR64i4Jblypx2w1BTTyrZk5l9EvTO+ZMq58E=";
  };

  propagatedBuildInputs = [
    azure-core
    typing-extensions
  ];

  # too complicated to set up
  doCheck = false;

  pythonImportsCheck = [
    "azure.eventhub"
    "azure.eventhub.aio"
  ];

  meta = with lib; {
    description = "Microsoft Azure Event Hubs Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/master/sdk/eventhub/azure-eventhub";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-eventhub_${version}/sdk/eventhub/azure-eventhub/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
}
