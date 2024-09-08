{ lib
, runCommandLocal
, runtimeShell
, substituteAll
, nix
, coreutils
, jq
, yq
, curl
, gnugrep
, gawk
, cacert
}:

runCommandLocal "nuget-to-nix" {
  script = substituteAll {
    src = ./nuget-to-nix.sh;
    inherit runtimeShell cacert;

    binPath = lib.makeBinPath [
      nix
      coreutils
      jq
      yq
      curl
      gnugrep
      gawk
    ];
  };

  meta.description = "Convert a nuget packages directory to a lockfile for buildDotnetModule";
} ''
  install -Dm755 $script $out/bin/nuget-to-nix
''
