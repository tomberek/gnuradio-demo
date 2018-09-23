{ stdenv, fetchFromGitHub
, cmake, flex, bison, pkgconfig
, glib, gtk2, gtkdatabox, matio, fftw, libxml2, avahi, curl, jansson, libaio
, libiio
, libad9361-iio
, pcre
, libpthreadstubs
, libXdmcp
, git
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  name = "iio-oscilloscope-${version}";
  version = "0.9";

  src = fetchFromGitHub {
    owner  = "analogdevicesinc";
    repo   = "iio-oscilloscope";
    #rev    = "refs/tags/v${version}-master";
    #rev    = "refs/tags/v${version}-master";
    rev = "master";
    sha256 = "16khdkg12dpr8hha7rr3057m3051b0xykhx50jl3cwgsc62kcv7j";
  };
  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DPREFIX=\"$out\""
    echo $NIX_CFLAGS_COMPILE
  '';
  cmakeFlags = [
    "-DGIT_COMMIT_TIMESTAMP=\"1537227313\"" 
    #"-DPREFIX=$out"
  ];
  makeFlags = [
    # "PREFIX=$out"
    "GIT_COMMIT_TIMESTAMP=\"1537227313\"" ];
  NIX_CFLAGS_COMPILE = [
    "-Wno-error=deprecated-declarations"
    "-Wno-error=int-in-bool-context"
    "-Wno-error=maybe-uninitialized"
    "-Wno-error=unused-function"
  ];
  patchPhase = ''
    substituteInPlace Makefile --replace \
      'GIT_COMMIT_TIMESTAMP := $(shell git show -s --pretty=format:"%ct" HEAD)' \
      "GIT_COMMIT_TIMESTMAP := 1"
    git init
    touch hi
    git add hi
    git commit -m "thing"

  '';
  postInstall = ''
    wrapGAppsHook
    echo PREFIX is $PREFIX
  '';

  nativeBuildInputs = [ git cmake flex bison pkgconfig wrapGAppsHook ];
  propagatedBuildInputs = [
    gtk2
    ];
  buildInputs = [
    pcre
    libpthreadstubs
    libXdmcp
    glib gtk2 gtkdatabox matio fftw libxml2 avahi curl jansson libaio libiio libad9361-iio ];

  meta = with stdenv.lib; {
    description = "A GTK+ based oscilloscope application for interfacing with various IIO devices";
    homepage    = https://github.com/analogdevicesinc/iio-oscilloscope;
    license     = licenses.lgpl21;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ tomberek ];
  };
}
