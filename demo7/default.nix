{ stdenv, fetchFromGitHub
, cmake, flex, bison
, libxml2
, libiio
}:

stdenv.mkDerivation rec {
  name = "libad9361-iio-${version}";
  version = "0.1";

  src = fetchFromGitHub {
    owner  = "analogdevicesinc";
    repo   = "libad9361-iio";
    rev    = "refs/tags/v${version}";
    sha256 = "0nfp0ykc30c3n4s9zsq2nyh1wv25hp6gs4n45nazzf6wf11dylgv";
  };

  nativeBuildInputs = [ cmake flex bison ];
  buildInputs = [ libxml2 libiio ];

  meta = with stdenv.lib; {
    description = "IIO AD9361 library for filter design and handling, multi-chip sync, etc.";
    homepage    = https://github.com/analogdevicesinc/libad9361-iio;
    license     = licenses.lgpl21;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ tomberek ];
  };
}
