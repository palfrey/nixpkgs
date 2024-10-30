{ lib
, fetchFromGitHub
, callPackage
, pkg-config
, cmake
, ninja
, python3
, gobject-introspection
, wrapGAppsHook3
, wrapQtAppsHook
, extra-cmake-modules
, qtbase
, qtwayland
, qtsvg
, qtimageformats
, gtk3
, glib-networking
, boost
, fmt
, libdbusmenu
, lz4
, xxHash
, ffmpeg
, openalSoft
, minizip
, libopus
, alsa-lib
, libpulseaudio
, pipewire
, range-v3
, tl-expected
, hunspell
, webkitgtk_4_1
, jemalloc
, rnnoise
, protobuf
, abseil-cpp
, xdg-utils
, microsoft-gsl
, rlottie
, ada
, stdenv
, darwin
, lld
, libicns
, nix-update-script
}:

# Main reference:
# - This package was originally based on the Arch package but all patches are now upstreamed:
#   https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/telegram-desktop
# Other references that could be useful:
# - https://git.alpinelinux.org/aports/tree/testing/telegram-desktop/APKBUILD
# - https://github.com/void-linux/void-packages/blob/master/srcpkgs/telegram-desktop/template

let
  tg_owt = callPackage ./tg_owt.nix {
    # tg_owt should use the same compiler
    inherit stdenv;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "telegram-desktop";
  version = "5.6.3";

  src = fetchFromGitHub {
    owner = "telegramdesktop";
    repo = "tdesktop";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-frz425V5eRulNVxCf457TWQAzU/f9/szD/sx3/LYQ2Y=";
  };

  patches = [
    ./macos.patch
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace-fail '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"'
    substituteInPlace Telegram/lib_webview/webview/platform/linux/webview_linux_webkitgtk_library.cpp \
      --replace-fail '"libwebkit2gtk-4.1.so.0"' '"${webkitgtk_4_1}/lib/libwebkit2gtk-4.1.so.0"'
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Telegram/lib_webrtc/webrtc/platform/mac/webrtc_environment_mac.mm \
      --replace-fail kAudioObjectPropertyElementMain kAudioObjectPropertyElementMaster
  '';

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapQtAppsHook
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    gobject-introspection
    wrapGAppsHook3
    extra-cmake-modules
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    lld
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtimageformats
    boost
    lz4
    xxHash
    ffmpeg
    openalSoft
    minizip
    libopus
    range-v3
    tl-expected
    rnnoise
    protobuf
    tg_owt
    microsoft-gsl
    rlottie
    ada
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    qtwayland
    gtk3
    glib-networking
    fmt
    libdbusmenu
    alsa-lib
    libpulseaudio
    pipewire
    hunspell
    webkitgtk_4_1
    jemalloc
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin (with darwin.apple_sdk_11_0.frameworks; [
    Cocoa
    CoreFoundation
    CoreServices
    CoreText
    CoreGraphics
    CoreMedia
    OpenGL
    AudioUnit
    ApplicationServices
    Foundation
    AGL
    Security
    SystemConfiguration
    Carbon
    AudioToolbox
    VideoToolbox
    VideoDecodeAcceleration
    AVFoundation
    CoreAudio
    CoreVideo
    CoreMediaIO
    QuartzCore
    AppKit
    CoreWLAN
    WebKit
    IOKit
    GSS
    MediaPlayer
    IOSurface
    Metal
    NaturalLanguage
    LocalAuthentication
    libicns
  ]);

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  cmakeFlags = [
    # We're allowed to used the API ID of the Snap package:
    (lib.cmakeFeature "TDESKTOP_API_ID" "611335")
    (lib.cmakeFeature "TDESKTOP_API_HASH" "d524b414d21f4d37f08684c1df41ac9c")
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -s $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    # This is necessary to run Telegram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    wrapQtApp $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}
  '';

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Telegram Desktop messaging app";
    longDescription = ''
      Desktop client for the Telegram messenger, based on the Telegram API and
      the MTProto secure protocol.
    '';
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    homepage = "https://desktop.telegram.org/";
    changelog = "https://github.com/telegramdesktop/tdesktop/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = if stdenv.hostPlatform.isLinux then "telegram-desktop" else "Telegram";
  };
})
