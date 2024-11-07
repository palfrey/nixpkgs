{ lib
, fetchFromGitHub
, rustPlatform
, stdenv
, installShellFiles
, pkg-config
, openssl
, mandown
, zellij
, testers
}:

rustPlatform.buildRustPackage rec {
  pname = "zellij";
  version = "0.41.1";

  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    rev = "v${version}";
    hash = "sha256-EUoJHM0Jm0uFKFeHhtzon/ZRC615SHfYa1gr4RnCNBw=";
  };

  cargoHash = "sha256-rI3pa0dvC/OVJz8gzD1bM0Q+8OWwvGj+jGDEMSbSb2I=";

  env.OPENSSL_NO_VENDOR = 1;

  nativeBuildInputs = [
    mandown
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  preCheck = ''
    HOME=$TMPDIR
  '';

  postInstall = ''
    mandown docs/MANPAGE.md > zellij.1
    installManPage zellij.1

  '' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd $pname \
      --bash <($out/bin/zellij setup --generate-completion bash) \
      --fish <($out/bin/zellij setup --generate-completion fish) \
      --zsh <($out/bin/zellij setup --generate-completion zsh)
  '';

  passthru.tests.version = testers.testVersion { package = zellij; };

  meta = with lib; {
    description = "Terminal workspace with batteries included";
    homepage = "https://zellij.dev/";
    changelog = "https://github.com/zellij-org/zellij/blob/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ therealansh _0x4A6F abbe pyrox0 ];
    mainProgram = "zellij";
  };
}
