{ stdenv, lib, tlpdb, bin, tlpdbxz, tl
, installShellFiles
, coreutils, findutils, gawk, getopt, ghostscript_headless, gnugrep
, gnumake, gnupg, gnused, gzip, html-tidy, ncurses, perl, python3, ruby, zip
}:

oldTlpdb:

let
  tlpdbVersion = tlpdb."00texlive.config";

    # most format -> engine links are generated by texlinks according to fmtutil.cnf at combine time
    # so we remove them from binfiles, and add back the ones texlinks purposefully ignore (e.g. mptopdf)
    removeFormatLinks = lib.mapAttrs (_: attrs:
      if (attrs ? formats && attrs ? binfiles)
      # TLPDB reports erroneously that various metafont binaries like "mf" are format links to engines
      # like "mf-nowin"; core-big provides both binaries and links so we simply skip them here
      then let formatLinks = lib.catAttrs "name" (lib.filter (f: f.name != f.engine && ! lib.hasSuffix "-nowin" f.engine) attrs.formats);
               binNotFormats = lib.subtractLists formatLinks attrs.binfiles;
           in if binNotFormats != [] then attrs // { binfiles = binNotFormats; } else removeAttrs attrs [ "binfiles" ]
      else attrs);

    orig = removeFormatLinks (removeAttrs oldTlpdb [ "00texlive.config" ]);

in lib.recursiveUpdate orig rec {
  #### overrides of texlive.tlpdb

  #### nonstandard script folders
  context-texlive.scriptsFolder = "context-texlive/stubs-mkiv/unix";
  cyrillic-bin.scriptsFolder = "texlive-extra";
  fontinst.scriptsFolder = "texlive-extra";
  mptopdf.scriptsFolder = "context/perl";
  pdftex.scriptsFolder = "simpdftex";
  texlive-scripts.scriptsFolder = "texlive";
  texlive-scripts-extra.scriptsFolder = "texlive-extra";
  xetex.scriptsFolder = "texlive-extra";

  #### interpreters not detected by looking at the script extensions
  ctanbib.extraBuildInputs = [ bin.luatex ];
  de-macro.extraBuildInputs = [ python3 ];
  match_parens.extraBuildInputs = [ ruby ];
  optexcount.extraBuildInputs = [ python3 ];
  pdfbook2.extraBuildInputs = [ python3 ];
  texlogsieve.extraBuildInputs = [ bin.luatex ];

  #### perl packages
  crossrefware.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ LWP URI ])) ];
  ctan-o-mat.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ LWP LWPProtocolHttps ])) ];
  ctanify.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ FileCopyRecursive ])) ];
  ctanupload.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ HTMLFormatter WWWMechanize ])) ];
  exceltex.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ SpreadsheetParseExcel ])) ];
  latex-git-log.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ IPCSystemSimple ])) ];
  latexindent.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ FileHomeDir LogDispatch LogLog4perl UnicodeLineBreak YAMLTiny ])) ];
  pax.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ FileWhich ])) ];
  pdflatexpicscale.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ GD ImageExifTool ])) ];
  ptex-fontmaps.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ Tk ])) ];
  purifyeps.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ FileWhich ])) ];
  sqltex.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ DBI ])) ];
  svn-multi.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ TimeDate ])) ];
  texdoctk.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ Tk ])) ];
  typog.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ IPCSystemSimple ])) ];
  ulqda.extraBuildInputs = [ (perl.withPackages (ps: with ps; [ DigestSHA1 ])) ];

  #### python packages
  pythontex.extraBuildInputs = [ (python3.withPackages (ps: with ps; [ pygments ])) ];

  #### other runtime PATH dependencies
  a2ping.extraBuildInputs = [ ghostscript_headless ];
  bibexport.extraBuildInputs = [ gnugrep ];
  checklistings.extraBuildInputs = [ coreutils ];
  cjk-gs-integrate.extraBuildInputs = [ ghostscript_headless ];
  cyrillic-bin.extraBuildInputs = [ coreutils gnused ];
  dtxgen.extraBuildInputs = [ coreutils getopt gnumake zip ];
  dviljk.extraBuildInputs = [ coreutils ];
  epspdf.extraBuildInputs = [ ghostscript_headless ];
  epstopdf.extraBuildInputs = [ ghostscript_headless ];
  fragmaster.extraBuildInputs = [ ghostscript_headless ];
  installfont.extraBuildInputs = [ coreutils getopt gnused ];
  latexfileversion.extraBuildInputs = [ coreutils gnugrep gnused ];
  listings-ext.extraBuildInputs = [ coreutils getopt ];
  ltxfileinfo.extraBuildInputs = [ coreutils getopt gnused ];
  ltximg.extraBuildInputs = [ ghostscript_headless ];
  luaotfload.extraBuildInputs = [ ncurses ];
  makeindex.extraBuildInputs = [ coreutils gnused ];
  pagelayout.extraBuildInputs = [ gnused ncurses ];
  pdfcrop.extraBuildInputs = [ ghostscript_headless ];
  pdftex.extraBuildInputs = [ coreutils ghostscript_headless gnused ];
  pdftex-quiet.extraBuildInputs = [ coreutils ];
  pdfxup.extraBuildInputs = [ coreutils ghostscript_headless ];
  pkfix-helper.extraBuildInputs = [ ghostscript_headless ];
  ps2eps.extraBuildInputs = [ ghostscript_headless ];
  pst2pdf.extraBuildInputs = [ ghostscript_headless ];
  tex4ebook.extraBuildInputs = [ html-tidy ];
  texlive-scripts.extraBuildInputs = [ gnused ];
  texlive-scripts-extra.extraBuildInputs = [ coreutils findutils ghostscript_headless gnused ];
  thumbpdf.extraBuildInputs = [ ghostscript_headless ];
  tpic2pdftex.extraBuildInputs = [ gawk ];
  wordcount.extraBuildInputs = [ coreutils gnugrep ];
  xdvi.extraBuildInputs = [ coreutils gnugrep ];
  xindy.extraBuildInputs = [ gzip ];

  #### adjustments to binaries
  # TODO patch the scripts from bin.* directly in bin.* instead of here

  # mptopdf is a format link, but not generated by texlinks
  # so we add it back to binfiles to generate it from mkPkgBin
  mptopdf.binfiles = (orig.mptopdf.binfiles or []) ++ [ "mptopdf" ];

  # remove man
  texlive-scripts.binfiles = lib.remove "man" orig.texlive-scripts.binfiles;
  # xindy is broken on some platforms unfortunately
  xindy.binfiles = if bin ? xindy
    then lib.subtractLists [ "xindy.mem" "xindy.run" ] orig.xindy.binfiles
    else [];

  #### additional symlinks
  cluttex.binlinks = {
    cllualatex = "cluttex";
    clxelatex = "cluttex";
  };

  context.binlinks = {
    context = "luametatex";
    "context.lua" = tl.context.tex + "/scripts/context/lua/context.lua";
    mtxrun = "luametatex";
    "mtxrun.lua" = tl.context.tex + "/scripts/context/lua/mtxrun.lua";
  };

  context-legacy.binlinks = {
    texexec = tl.context-legacy.tex + "/scripts/context/ruby/texexec.rb";
    texmfstart = tl.context-legacy.tex + "/scripts/context/ruby/texmfstart.rb";
  };

  epstopdf.binlinks.repstopdf = "epstopdf";
  pdfcrop.binlinks.rpdfcrop = "pdfcrop";

  # TODO: handle symlinks in bin.core
  ptex.binlinks = {
    pbibtex = tl.uptex.out + "/bin/upbibtex";
    pdvitype = tl.uptex.out + "/bin/updvitype";
    ppltotf = tl.uptex.out + "/bin/uppltotf";
    ptftopl = tl.uptex.out + "/bin/uptftopl";
  };

  texdef.binlinks = {
    latexdef = "texdef";
  };

  texlive-scripts.binlinks = {
    mktexfmt = "fmtutil";
    texhash = tl."texlive.infra".out + "/bin/mktexlsr";
  };

  texlive-scripts-extra.binlinks = {
    allec = "allcm";
    kpsepath = "kpsetool";
    kpsexpand = "kpsetool";
  };

  #### add PATH dependencies without wrappers
  # TODO deduplicate this code
  a2ping.postFixup = ''
    sed -i '6i$ENV{PATH}='"'"'${lib.makeBinPath a2ping.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/a2ping
  '';

  bibexport.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath bibexport.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/bibexport
  '';

  checklistings.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath checklistings.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/checklistings
  '';

  cjk-gs-integrate.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath cjk-gs-integrate.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/cjk-gs-integrate
  '';

  cyrillic-bin.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath cyrillic-bin.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/rumakeindex
  '';

  dtxgen.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath dtxgen.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/dtxgen
  '';

  dviljk.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath dviljk.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/dvihp
  '';

  epstopdf.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath epstopdf.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/epstopdf
  '';

  fragmaster.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath fragmaster.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/fragmaster
  '';

  installfont.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath installfont.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/installfont-tl
  '';

  latexfileversion.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath latexfileversion.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/latexfileversion
  '';

  listings-ext.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath listings-ext.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/listings-ext.sh
  '';

  ltxfileinfo.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath ltxfileinfo.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/ltxfileinfo
  '';

  ltximg.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath ltximg.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/ltximg
  '';

  luaotfload.postFixup = ''
    sed -i '2ios.setenv("PATH","${lib.makeBinPath luaotfload.extraBuildInputs}" .. (os.getenv("PATH") and ":" .. os.getenv("PATH") or ""))' "$out"/bin/luaotfload-tool
  '';

  makeindex.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath makeindex.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/mkindex
  '';

  pagelayout.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath [ gnused ]}''${PATH:+:$PATH}"' "$out"/bin/pagelayoutapi
    sed -i '2iPATH="${lib.makeBinPath [ ncurses ]}''${PATH:+:$PATH}"' "$out"/bin/textestvis
  '';

  pdfcrop.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath pdfcrop.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/pdfcrop
  '';

  pdftex.postFixup = ''
    sed -i -e '2iPATH="${lib.makeBinPath [ coreutils gnused ]}''${PATH:+:$PATH}"' \
      -e 's!^distillerpath="/usr/local/bin"$!distillerpath="${lib.makeBinPath [ ghostscript_headless ]}"!' \
      "$out"/bin/simpdftex
  '';

  pdftex-quiet.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath pdftex-quiet.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/pdftex-quiet
  '';

  pdfxup.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath pdfxup.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/pdfxup
  '';

  pkfix-helper.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath pkfix-helper.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/pkfix-helper
  '';

  ps2eps.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath ps2eps.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/ps2eps
  '';

  pst2pdf.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath pst2pdf.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/pst2pdf
  '';

  tex4ebook.postFixup = ''
    sed -i '2ios.setenv("PATH","${lib.makeBinPath tex4ebook.extraBuildInputs}" .. (os.getenv("PATH") and ":" .. os.getenv("PATH") or ""))' "$out"/bin/tex4ebook
  '';

  texlive-scripts.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath texlive-scripts.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/{fmtutil-user,mktexmf,mktexpk,mktextfm,updmap-user}
  '';

  thumbpdf.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath thumbpdf.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/thumbpdf
  '';

  tpic2pdftex.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath tpic2pdftex.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/tpic2pdftex
  '';

  wordcount.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath wordcount.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/wordcount
  '';

  # TODO patch in bin.xdvi
  xdvi.postFixup = ''
    sed -i '2iPATH="${lib.makeBinPath xdvi.extraBuildInputs}''${PATH:+:$PATH}"' "$out"/bin/xdvi
  '';

  xindy.postFixup = ''
    sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath xindy.extraBuildInputs}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/{texindy,xindy}
  '';

  #### other script fixes
  # misc tab and python3 fixes
  ebong.postFixup = ''
    sed -Ei 's/import sre/import re/; s/file\(/open(/g; s/\t/        /g; s/print +(.*)$/print(\1)/g' "$out"/bin/ebong
  '';

  # find files in script directory, not binary directory
  # add runtime dependencies to PATH
  epspdf.postFixup = ''
    sed -i '2ios.setenv("PATH","${lib.makeBinPath epspdf.extraBuildInputs}" .. (os.getenv("PATH") and ":" .. os.getenv("PATH") or ""))' "$out"/bin/epspdf
    substituteInPlace "$out"/bin/epspdftk --replace-fail '[info script]' "\"$scriptsFolder/epspdftk.tcl\""
  '';

  # find files in script directory, not in binary directory
  latexindent.postFixup = ''
    substituteInPlace "$out"/bin/latexindent --replace-fail 'use FindBin;' "BEGIN { \$0 = '$scriptsFolder' . '/latexindent.pl'; }; use FindBin;"
  '';

  # find files in script directory, not in binary directory
  minted.postFixup = ''
    substituteInPlace "$out"/bin/latexminted --replace-fail "__file__" "\"$scriptsFolder/latexminted.py\""
  '';

  # flag lua dependency
  texblend.scriptExts = [ "lua" ];

  # Patch texlinks.sh back to 2015 version;
  # otherwise some bin/ links break, e.g. xe(la)tex.
  # add runtime dependencies to PATH
  texlive-scripts-extra.postFixup = ''
    patch -R "$out"/bin/texlinks < '${./texlinks.diff}'
    sed -i '2iPATH="${lib.makeBinPath [ coreutils ]}''${PATH:+:$PATH}"' "$out"/bin/{allcm,dvired,mkocp,ps2frag}
    sed -i '2iPATH="${lib.makeBinPath [ coreutils findutils ]}''${PATH:+:$PATH}"' "$out"/bin/allneeded
    sed -i '2iPATH="${lib.makeBinPath [ coreutils ghostscript_headless ]}''${PATH:+:$PATH}"' "$out"/bin/dvi2fax
    sed -i '2iPATH="${lib.makeBinPath [ gnused ]}''${PATH:+:$PATH}"' "$out"/bin/{kpsetool,texconfig,texconfig-sys}
    sed -i '2iPATH="${lib.makeBinPath [ coreutils gnused ]}''${PATH:+:$PATH}"' "$out"/bin/texconfig-dialog
  '';

  # patch interpreter
  texosquery.postFixup = ''
    substituteInPlace "$out"/bin/* --replace-fail java "$interpJava"
  '';

  # hardcode revision numbers (since texlive.infra, tlshell are not in either system or user texlive.tlpdb)
  tlshell.postFixup = ''
    substituteInPlace "$out"/bin/tlshell \
      --replace-fail '[dict get $::pkgs texlive.infra localrev]' '${toString orig."texlive.infra".revision}' \
      --replace-fail '[dict get $::pkgs tlshell localrev]' '${toString orig.tlshell.revision}'
  '';

  #### dependency changes
  # it seems to need it to transform fonts
  xdvi.deps = (orig.xdvi.deps or [ ]) ++ [ "metafont" ];

  mltex.deps = (orig.mltex.deps or [ ]) ++ [ "pdftex" ];

  # remove dependency-heavy packages from the basic collections
  collection-basic.deps = lib.subtractLists [ "metafont" "xdvi" ] orig.collection-basic.deps;

  # add them elsewhere so that collections cover all packages
  collection-metapost.deps = orig.collection-metapost.deps ++ [ "metafont" ];
  collection-plaingeneric.deps = orig.collection-plaingeneric.deps ++ [ "xdvi" ];

  #### misc

  # RISC-V: https://github.com/LuaJIT/LuaJIT/issues/628
  luajittex.binfiles = lib.optionals
    (!(stdenv.hostPlatform.isPower && stdenv.hostPlatform.is64bit) && !stdenv.hostPlatform.isRiscV)
    orig.luajittex.binfiles;

  # osda is unfree. Hence, we can't include it by default
  collection-publishers.deps = builtins.filter (dep: dep != "osda") orig.collection-publishers.deps;

  texdoc = {
    extraRevision = "-tlpdb${toString tlpdbVersion.revision}";
    extraVersion = "-tlpdb-${toString tlpdbVersion.revision}";

    extraNativeBuildInputs = [ installShellFiles ];

    # build Data.tlpdb.lua (part of the 'tlType == "run"' package)
    postUnpack = ''
      if [[ -f "$out"/scripts/texdoc/texdoc.tlu ]]; then
        unxz --stdout "${tlpdbxz}" > texlive.tlpdb

        # create dummy doc file to ensure that texdoc does not return an error
        mkdir -p support/texdoc
        touch support/texdoc/NEWS

        TEXMFCNF="${tl.kpathsea.tex}/web2c" TEXMF="$out" TEXDOCS=. TEXMFVAR=. \
          "${bin.luatex}"/bin/texlua "$out"/scripts/texdoc/texdoc.tlu \
          -c texlive_tlpdb=texlive.tlpdb -lM texdoc

        cp texdoc/cache-tlpdb.lua "$out"/scripts/texdoc/Data.tlpdb.lua
      fi
    '';

    # install zsh completion
    postFixup = ''
      TEXMFCNF="${tl.kpathsea.tex}"/web2c TEXMF="$scriptsFolder/../.." \
        texlua "$out"/bin/texdoc --print-completion zsh > "$TMPDIR"/_texdoc
      substituteInPlace "$TMPDIR"/_texdoc \
        --replace-fail 'compdef __texdoc texdoc' '#compdef texdoc' \
        --replace-fail '$(kpsewhich -var-value TEXMFROOT)/tlpkg/texlive.tlpdb' '$(kpsewhich Data.tlpdb.lua)' \
        --replace-fail '/^name[^.]*$/ {print $2}' '/^  \["[^"]*"\] = {$/ { print substr($1,3,length($1)-4) }'
      echo '__texdoc' >> "$TMPDIR"/_texdoc
      installShellCompletion --zsh "$TMPDIR"/_texdoc
    '';
  };

  "texlive.infra" = {
    extraRevision = ".tlpdb${toString tlpdbVersion.revision}";
    extraVersion = "-tlpdb-${toString tlpdbVersion.revision}";

    # add license of tlmgr and TeXLive::* perl packages and of bin.core
    license = [ "gpl2Plus" ] ++ lib.toList bin.core.meta.license.shortName ++ orig."texlive.infra".license or [ ];

    scriptsFolder = "texlive";
    extraBuildInputs = [ coreutils gnused gnupg tl.kpathsea (perl.withPackages (ps: with ps; [ Tk ])) ];

    # make tlmgr believe it can use kpsewhich to evaluate TEXMFROOT
    postFixup = ''
      substituteInPlace "$out"/bin/tlmgr \
        --replace-fail 'if (-r "$bindir/$kpsewhichname")' 'if (1)'
      sed -i '2i$ENV{PATH}='"'"'${lib.makeBinPath [ gnupg ]}'"'"' . ($ENV{PATH} ? ":$ENV{PATH}" : '"'''"');' "$out"/bin/tlmgr
      sed -i '2iPATH="${lib.makeBinPath [ coreutils gnused tl.kpathsea ]}''${PATH:+:$PATH}"' "$out"/bin/mktexlsr
    '';

    # add minimal texlive.tlpdb
    postUnpack = ''
      if [[ -d "$out"/TeXLive ]] ; then
        xzcat "${tlpdbxz}" | sed -n -e '/^name \(00texlive.config\|00texlive.installation\)$/,/^$/p' > "$out"/texlive.tlpdb
      fi
    '';
  };
}
