{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  python3,
  openssl,
  libgpg-error,
  gpgme,
  xorg,
  nettle,
  installShellFiles,
}:

rustPlatform.buildRustPackage rec {
  version = "0.7.0";
  pname = "ripasso-cursive";

  src = fetchFromGitHub {
    owner = "cortex";
    repo = "ripasso";
    rev = "release-${version}";
    hash = "sha256-j98X/+UTea4lCtFfMpClnfcKlvxm4DpOujLc0xc3VUY=";
  };

  cargoHash = "sha256-dP8H4OOgtQEBEJxpbaR3KnXFtgBdX4r+dCpBJjBK1MM=";

  patches = [
    ./fix-tests.patch
  ];

  cargoBuildFlags = [ "-p ripasso-cursive" ];

  nativeBuildInputs = [
    pkg-config
    gpgme
    python3
    installShellFiles
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    libgpg-error
    gpgme
    xorg.libxcb
    nettle
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    installManPage target/man-page/cursive/ripasso-cursive.1
  '';

  meta = with lib; {
    description = "Simple password manager written in Rust";
    mainProgram = "ripasso-cursive";
    homepage = "https://github.com/cortex/ripasso";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sgo ];
    platforms = platforms.unix;
  };
}
