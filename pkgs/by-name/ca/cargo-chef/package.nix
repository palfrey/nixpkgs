{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-chef";
  version = "0.1.69";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-zDVolVllWl0DM0AByglKhU8JQpkdcmyVGe1vYo+eamk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-3bjnAQLIO0hHjkRDym2oUzmiMd2gp5gN+iK8NxBC22Q=";

  meta = with lib; {
    description = "Cargo-subcommand to speed up Rust Docker builds using Docker layer caching";
    mainProgram = "cargo-chef";
    homepage = "https://github.com/LukeMathWalker/cargo-chef";
    license = licenses.mit;
    maintainers = with maintainers; [ kkharji ];
  };
}
