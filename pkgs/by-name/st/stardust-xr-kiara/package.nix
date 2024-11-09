{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  niri,
  stardust-xr-kiara,
  testers,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "stardust-xr-kiara";
  version = "0-unstable-2024-07-07";

  src = fetchFromGitHub {
    owner = "stardustxr";
    repo = "kiara";
    rev = "7daaa0a2e3822d949e6c4abf93af159eae9a544a";
    hash = "sha256-5j83e2kcCStPgbwAkr3OFjOpJIErXAPJ6z06BlmtuHE=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "stardust-xr-0.14.1" = "sha256-fmRb46s0Ec8wnoerBh4JCv1WKz2of1YW+YGwy0Gr/yQ=";
      "stardust-xr-molecules-0.29.0" = "sha256-sXwzrh052DCo7Jj1waebqKVmX8J9VRj5DpeUcGq3W2k=";
    };
  };
  nativeBuildInputs = [ makeBinaryWrapper ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
    tests.helpTest = testers.runCommand {
      name = "stardust-xr-kiara";
      script = ''
        kiara --help
        touch $out
      '';
      nativeBuildInputs = [ stardust-xr-kiara ];
    };
  };

  postInstall = ''
    wrapProgram $out/bin/kiara --prefix PATH : ${niri}/bin
  '';

  env = {
    NIRI_CONFIG = "${src}/src/niri_config.kdl";
    STARDUST_RES_PREFIXES = "${src}/res";
  };

  meta = {
    description = "A 360-degree app shell / DE for Stardust XR using Niri";
    homepage = "https://stardustxr.org/";
    license = lib.licenses.mit;
    mainProgram = "kiara";
    maintainers = with lib.maintainers; [
      pandapip1
      technobaboo
    ];
    platforms = lib.platforms.linux;
  };
}
