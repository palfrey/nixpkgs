{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, cmake
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "subxt";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "paritytech";
    repo = "subxt";
    rev = "v${version}";
    hash = "sha256-mUW1foT3JkpsnieJutL+GZZXiTcRUklnjfoaWcH8ccE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-DcoD74uxO1aGZ50qVnfPiCRsQf3G0E0ANX33WdLSNOo=";

  # Only build the command line client
  cargoBuildFlags = [ "--bin" "subxt" ];

  # Needed by wabt-sys
  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  # Requires a running substrate node
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/paritytech/subxt";
    description = "Submit transactions to a substrate node via RPC";
    mainProgram = "subxt";
    license = with licenses; [ gpl3Plus asl20 ];
    maintainers = [ maintainers.FlorianFranzen ];
  };
}
