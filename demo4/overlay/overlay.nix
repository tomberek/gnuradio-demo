self: super: {
  gnuradio = with super; super.gnuradio.overrideAttrs (old: {
  postInstall = ''
    printf "backend : Qt4Agg\n" > "$out/share/gnuradio/matplotlibrc"

    for file in $(find $out/bin $out/share/gnuradio/examples -type f -executable); do
        wrapProgram "$file" \
            --suffix PYTHONPATH : $PYTHONPATH:$(toPythonPath "$out") \
            --set MATPLOTLIBRC "$out/share/gnuradio" \
            ${stdenv.lib.optionalString stdenv.isDarwin "--set DYLD_FRAMEWORK_PATH /System/Library/Frameworks"}
    done
  '';
  });
}
