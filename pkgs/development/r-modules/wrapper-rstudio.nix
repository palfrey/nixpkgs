{
  runCommand,
  R,
  rstudio,
  makeWrapper,
  recommendedPackages,
  packages,
  fontconfig,
}:

runCommand (rstudio.name + "-wrapper")
  {
    preferLocalBuild = true;
    allowSubstitutes = false;

    nativeBuildInputs = [ makeWrapper ];
    dontWrapQtApps = true;

    buildInputs =
      [
        R
        rstudio
      ]
      ++ recommendedPackages
      ++ packages;

    # rWrapper points R to a specific set of packages by using a wrapper
    # (as in https://nixos.org/nixpkgs/manual/#r-packages) which sets
    # R_LIBS_SITE.  Ordinarily, it would be possible to make RStudio use
    # this same set of packages by simply overriding its version of R
    # with the wrapped one, however, RStudio internally overrides
    # R_LIBS_SITE.  The below works around this by turning R_LIBS_SITE
    # into an R file (fixLibsR) which achieves the same effect, then
    # uses R_PROFILE_USER to load this code at startup in RStudio.
    fixLibsR = "fix_libs.R";
  }
  (
    ''
      mkdir -p $out
      echo "# Autogenerated by wrapper-rstudio.nix from R_LIBS_SITE" > $out/$fixLibsR
      echo -n ".libPaths(c(.libPaths(), \"" >> $out/$fixLibsR
      echo -n $R_LIBS_SITE | sed -e 's/:/", "/g' >> $out/$fixLibsR
      echo -n "\"))" >> $out/$fixLibsR
      echo >> $out/$fixLibsR
    ''
    + (
      if rstudio.server then
        ''
          makeWrapper ${rstudio}/bin/rsession $out/bin/rsession \
            --set R_PROFILE_USER $out/$fixLibsR --set FONTCONFIG_FILE ${fontconfig.out}/etc/fonts/fonts.conf

          makeWrapper ${rstudio}/bin/rserver $out/bin/rserver \
            --add-flags --rsession-path=$out/bin/rsession
        ''
      else
        ''
          ln -s ${rstudio}/share $out
          makeWrapper ${rstudio}/bin/rstudio $out/bin/rstudio \
            --set R_PROFILE_USER $out/$fixLibsR
        ''
    )
  )
