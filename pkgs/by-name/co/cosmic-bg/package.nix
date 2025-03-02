{
  lib,
  stdenv,
  stdenvAdapters,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  nasm,

  withMoldLinker ? stdenv.targetPlatform.isLinux,
}:

rustPlatform.buildRustPackage.override
  { stdenv = if withMoldLinker then stdenvAdapters.useMoldLinker stdenv else stdenv; }
  rec {
    pname = "cosmic-bg";
    version = "1.0.0-alpha.6";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "cosmic-bg";
      tag = "epoch-${version}";
      hash = "sha256-4b4laUXTnAbdngLVh8/dD144m9QrGReSEjRZoNR6Iks=";
    };

    useFetchCargoVendor = true;
    cargoHash = "sha256-GLXooTjcGq4MsBNnlpHBBUJGNs5UjKMQJGJuj9UO2wk=";

    nativeBuildInputs = [
      just
      libcosmicAppHook
      nasm
    ];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    justFlags = [
      "--set"
      "prefix"
      (placeholder "out")
      "--set"
      "bin-src"
      "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-bg"
    ];

    env."CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_RUSTFLAGS" =
      lib.optionalString withMoldLinker "-C link-arg=-fuse-ld=mold";

    meta = {
      homepage = "https://github.com/pop-os/cosmic-bg";
      description = "Applies Background for the COSMIC Desktop Environment";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ nyabinary ];
      platforms = lib.platforms.linux;
      mainProgram = "cosmic-bg";
    };
  }
