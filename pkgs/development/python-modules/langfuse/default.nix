{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  anyio,
  backoff,
  httpx,
  idna,
  langchain,
  llama-index,
  openai,
  packaging,
  poetry-core,
  pydantic,
  wrapt,
}:

buildPythonPackage rec {
  pname = "langfuse";
  version = "2.57.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "langfuse";
    repo = "langfuse-python";
    tag = "v${version}";
    hash = "sha256-H05UsHT6xPyqC/x7YIPSxk9/MMla8sEabz1tmIOKWWE=";
  };

  build-system = [ poetry-core ];

  pythonRelaxDeps = [ "packaging" ];

  dependencies = [
    anyio
    backoff
    httpx
    idna
    packaging
    pydantic
    wrapt
  ];

  optional-dependencies = {
    langchain = [ langchain ];
    llama-index = [ llama-index ];
    openai = [ openai ];
  };

  pythonImportsCheck = [ "langfuse" ];

  # tests require network access and openai api key
  doCheck = false;

  meta = {
    description = "Instrument your LLM app with decorators or low-level SDK and get detailed tracing/observability";
    homepage = "https://github.com/langfuse/langfuse-python";
    changelog = "https://github.com/langfuse/langfuse-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
