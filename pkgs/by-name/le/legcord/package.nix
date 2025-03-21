{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_9,
  nodejs,
  electron_34,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
}:
stdenv.mkDerivation rec {
  pname = "legcord";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Legcord";
    repo = "Legcord";
    rev = "v${version}";
    hash = "sha256-0RbLvRCvy58HlOhHLcAoErRFgYxjWrKFQ6DPJD50c5Q=";
  };

  nativeBuildInputs = [
    pnpm_9.configHook
    nodejs
    makeWrapper
    copyDesktopItems
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version src;
    hash = "sha256-UivO0e50zGNV69AaV4RilmJ9L6L6lctUrUh9CVIOry4=";
  };

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    pnpm build

    npm exec electron-builder -- \
      --dir \
      -c.electronDist="${electron_34.dist}" \
      -c.electronVersion="${electron_34.version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/lib/legcord"
    cp -r ./dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/legcord"

    install -Dm644 "build/icon.png" "$out/share/icons/hicolor/256x256/apps/legcord.png"

    makeShellWrapper "${lib.getExe electron_34}" "$out/bin/legcord" \
      --add-flags "$out/share/lib/legcord/resources/app.asar" \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "legcord";
      desktopName = "Legcord";
      exec = "legcord %U";
      icon = "legcord";
      comment = meta.description;
      categories = [ "Network" ];
      startupWMClass = "Legcord";
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Lightweight, alternative desktop client for Discord";
    homepage = "https://legcord.app";
    downloadPage = "https://github.com/Legcord/Legcord";
    license = licenses.osl3;
    maintainers = with maintainers; [
      wrmilling
      water-sucks
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "legcord";
  };
}
