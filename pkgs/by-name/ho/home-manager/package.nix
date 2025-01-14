{
  lib,
  bash,
  coreutils,
  fetchFromGitHub,
  findutils,
  gettext,
  gnused,
  inetutils,
  installShellFiles,
  jq,
  less,
  ncurses,
  nixos-option,
  stdenvNoCC,
  unixtools,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "home-manager";
  version = "0-unstable-2025-01-13";

  src = fetchFromGitHub {
    name = "home-manager-source";
    owner = "nix-community";
    repo = "home-manager";
    rev = "fc52a210b60f2f52c74eac41a8647c1573d2071d";
    hash = "sha256-TY0jUwR3EW0fnS0X5wXMAVy6h4Z7Y6a3m+Yq++C9AyE=";
  };

  nativeBuildInputs = [
    gettext
    installShellFiles
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -m755 home-manager/home-manager $out/bin/home-manager
    install -D -m755 lib/bash/home-manager.sh $out/share/bash/home-manager.sh

    installShellCompletion --cmd home-manager \
      --bash home-manager/completion.bash \
      --fish home-manager/completion.fish \
      --zsh home-manager/completion.zsh

    for pofile in home-manager/po/*.po; do
      lang="''${pofile##*/}"
      lang="''${lang%%.*}"
      mkdir -p "$out/share/locale/$lang/LC_MESSAGES"
      msgfmt -o "$out/share/locale/$lang/LC_MESSAGES/home-manager.mo" "$pofile"
    done

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/bin/home-manager \
      --subst-var-by bash "${bash}" \
      --subst-var-by DEP_PATH "${
        lib.makeBinPath [
          coreutils
          findutils
          gettext
          gnused
          jq
          less
          ncurses
          nixos-option
          inetutils # for `hostname`
        ]
      }" \
      --subst-var-by HOME_MANAGER_LIB "$out/share/bash/home-manager.sh" \
      --subst-var-by HOME_MANAGER_PATH "${finalAttrs.src}" \
      --subst-var-by OUT "$out"
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/nix-community/home-manager/";
  };

  meta = {
    homepage = "https://nix-community.github.io/home-manager/";
    description = "Nix-based user environment configurator";
    longDescription = ''
      The Home-Manager project provides a basic system for managing a user
      environment using the Nix package manager together with the Nix libraries
      found in Nixpkgs. It allows declarative configuration of user specific
      (non global) packages and dotfiles.
    '';
    license = lib.licenses.mit;
    mainProgram = "home-manager";
    maintainers = with lib.maintainers; [ bryango ];
    platforms = lib.platforms.unix;
  };
})
