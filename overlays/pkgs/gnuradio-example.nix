{ stdenv, fetchFromGitHub, cmake, pkgconfig, boost, gnuradio, uhd
, makeWrapper, cppunit
, pythonSupport ? true, python, swig
}:

assert pythonSupport -> python != null && swig != null;

stdenv.mkDerivation rec {
  name = "gnuradio-example-${version}";
  version = "0.0.1";

  src = ../../gr-example;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    cmake boost uhd makeWrapper gnuradio cppunit
  ] ++ stdenv.lib.optionals pythonSupport [ python swig ];
  propagatedBuildInputs = [ gnuradio ];

  postInstall = ''
    for prog in "$out"/bin/*; do
        wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Example Gnuradio block for Nix";
    homepage = https://github.com/tomberek/gr-example;
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ tomberek ];
  };
}
