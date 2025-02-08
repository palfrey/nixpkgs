{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  fetchurl,
}:

# This file is responsible for fetching the sage source and adding necessary patches.
# It does not actually build anything, it just copies the patched sources to $out.
# This is done because multiple derivations rely on these sources and they should
# all get the same sources with the same patches applied.

stdenv.mkDerivation rec {
  version = "10.5";
  pname = "sage-src";

  src = fetchFromGitHub {
    owner = "sagemath";
    repo = "sage";
    rev = version;
    hash = "sha256-OiGMc3KyHWnjVWXJ/KiqEQS1skM9nPLYcoMK9kw4718=";
  };

  # contains essential files (e.g., setup.cfg) generated by the bootstrap script.
  # TODO: investigate https://github.com/sagemath/sage/pull/35950
  configure-src = fetchurl {
    # the hash below is the tagged commit's _parent_. it can also be found by looking for
    # the "configure" asset at https://github.com/sagemath/sage/releases/tag/${version}
    url = "mirror://sageupstream/configure/configure-f6ad0ecf1f4a269f5954d5487336b13f70624594.tar.gz";
    hash = "sha256-VANtZDUhjOHap9XVEuG/1003E+1XRdXEnuH15hIqJd4=";
  };

  # Patches needed because of particularities of nix or the way this is packaged.
  # The goal is to upstream all of them and get rid of this list.
  nixPatches =
    [
      # Parallelize docubuild using subprocesses, fixing an isolation issue. See
      # https://groups.google.com/forum/#!topic/sage-packaging/YGOm8tkADrE
      ./patches/sphinx-docbuild-subprocesses.patch

      # After updating smypow to (https://github.com/sagemath/sage/issues/3360)
      # we can now set the cache dir to be within the .sage directory. This is
      # not strictly necessary, but keeps us from littering in the user's HOME.
      ./patches/sympow-cache.patch
    ]
    ++ lib.optionals (stdenv.cc.isClang) [
      # https://github.com/NixOS/nixpkgs/pull/264126
      # Dead links in python sysconfig cause LLVM linker warnings, leading to cython doctest failures.
      ./patches/silence-linker.patch

      # Stack overflows during doctests; this does not change functionality.
      ./patches/disable-singular-doctest.patch
    ];

  # Since sage unfortunately does not release bugfix releases, packagers must
  # fix those bugs themselves. This is for critical bugfixes, where "critical"
  # == "causes (transient) doctest failures / somebody complained".
  bugfixPatches = [
    # compile libs/gap/element.pyx with -O1
    # a more conservative version of https://github.com/sagemath/sage/pull/37951
    ./patches/gap-element-crash.patch

    # https://github.com/sagemath/sage/pull/38940, landed in 10.6.beta0
    (fetchpatch {
      name = "simplicial-sets-flaky-test.patch";
      url = "https://github.com/sagemath/sage/commit/1830861c5130d30b891e8c643308e1ceb91ce2b5.diff";
      hash = "sha256-6MbZ+eJPFBEtnJsJX0MgO2AykPXSeuya0W0adiIH+KE=";
    })
  ];

  # Patches needed because of package updates. We could just pin the versions of
  # dependencies, but that would lead to rebuilds, confusion and the burdons of
  # maintaining multiple versions of dependencies. Instead we try to make sage
  # compatible with never dependency versions when possible. All these changes
  # should come from or be proposed to upstream. This list will probably never
  # be empty since dependencies update all the time.
  packageUpgradePatches = [
    # https://github.com/sagemath/sage/pull/38887, landed in 10.6.beta0
    (fetchpatch {
      name = "libbraiding-1.3-update.patch";
      url = "https://github.com/sagemath/sage/commit/f10a6d04599795732c1d99e2da0a4839ccdcb4f5.diff";
      hash = "sha256-xB0xg8dGLnSMdFK3/B5hkI9yzI5N3lUMhPZ89lDsp3s=";
    })

    # https://github.com/sagemath/sage/pull/38749, to land in 10.6.beta6
    (fetchpatch {
      name = "pari-2.17.1-update.patch";
      url = "https://github.com/sagemath/sage/compare/10.6.beta2...26f411e5939718d4439325ff669635e5a72d50e5.diff";
      hash = "sha256-Z4JwCuUDpqktAzNtVKRUbrJEh7TmCtFI7PJnOrcEbr4=";
    })
  ];

  patches = nixPatches ++ bugfixPatches ++ packageUpgradePatches;

  # do not create .orig backup files if patch applies with fuzz
  patchFlags = [
    "--no-backup-if-mismatch"
    "-p1"
  ];

  # harmless broken symlinks to (not) generated files used by sage-the-distro
  dontCheckForBrokenSymlinks = true;

  postPatch = ''
    # Make sure sage can at least be imported without setting any environment
    # variables. It won't be close to feature complete though.
    sed -i \
      "s|var(\"SAGE_ROOT\".*|var(\"SAGE_ROOT\", \"$out\")|" \
      src/sage/env.py

    # sage --docbuild unsets JUPYTER_PATH, which breaks our docbuilding
    # https://trac.sagemath.org/ticket/33650#comment:32
    sed -i "/export JUPYTER_PATH/d" src/bin/sage
  '';

  buildPhase = "# do nothing";

  installPhase = ''
    cp -r . "$out"
    tar xzf ${configure-src} -C "$out"
    rm "$out/configure"
  '';
}
