{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  pkg-config,
  hyprland-protocols,
  hyprutils,
  hyprwayland-scanner,
  wayland,
  wayland-protocols,
  wayland-scanner,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hyprsunset";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprsunset";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EIJka3UtSEtmkDBjYiGeR/hO6s6R4x3K+rbUlc9KPBE=";
  };

  postPatch = ''
    # hyprwayland-scanner is not required at runtime
    substituteInPlace CMakeLists.txt --replace-fail "hyprwayland-scanner>=0.4.0" ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    hyprwayland-scanner
  ];

  buildInputs = [
    hyprland-protocols
    hyprutils
    wayland
    wayland-protocols
    wayland-scanner
  ];

  strictDeps = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://github.com/hyprwm/hyprsunset";
    description = "Application to enable a blue-light filter on Hyprland";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = lib.teams.hyprland.members;
    mainProgram = "hyprsunset";
  };
})
