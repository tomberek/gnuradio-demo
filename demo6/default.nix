# To update, visit https://nixos.org/channels/nixpkgs-unstable
let
  nixpkgs2 = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-18.09pre147772.d1ae60cbad7/nixexprs.tar.xz";
    sha256 = "178vva8wxiy4lkpz2sdi7a9s92fdrmfg2ch5b0rbd24pxpv4xbrb";
  };
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {
    overlays =
      [
        (import  ../gr-example/overlay.nix)
        # (import  ../demo7/overlays/overlay.nix)
        # (import  ../gr-iio/overlay.nix)
      ];
  };

  gnuradio-wrap = { stdenv, gnuradio, makeWrapper, python, extraPackages ? [] }:

    with { inherit (stdenv.lib) appendToName makeSearchPath; };

    stdenv.mkDerivation rec {
      name = (appendToName "with-packages" gnuradio).name;
      buildInputs = [ makeWrapper python ];
      env = pkgs.buildEnv {
        inherit name;
        ignoreCollisions = true;
        paths = let 
          path_1 = builtins.map ( drv : pkgs.pythonPackages.toPythonModule drv ) ([gnuradio] ++ extraPackages);
          path_2 = gnuradio.propagatedBuildInputs;
          in path_1 ++ path_2;
      };

                  #--prefix PYTHONPATH : ${stdenv.lib.concatStringsSep ":"
                  #                         (map (path: "$(toPythonPath ${path})") extraPackages)} \
    buildCommand = ''
      mkdir -p $out/bin
      ln -s "${gnuradio}"/bin/* $out/bin/

      for file in $(find -L $out/bin -type f ); do
          if test -x "$(readlink -f "$file")"; then
              wrapProgram "$file" \
                  --prefix PYTHONPATH : "$(toPythonPath ${env})" \
                  --prefix GRC_BLOCKS_PATH : ${makeSearchPath "share/gnuradio/grc/blocks" extraPackages}
          fi
      done
    '';

    inherit (gnuradio) meta;
  };

  gnuradio-wrap2 = pkgs.callPackage gnuradio-wrap {inherit gnuradio;};
  gnuradio-with-packages = gnuradio-wrap2.override {
    extraPackages = [
      (pkgs.gnuradio-example.overrideAttrs (old:{
        python=pkgs.python3;
      }))
      #pkgs.gnuradio-iio
      ];
  };
  gnuradio = pkgs.gnuradio.overrideAttrs (old: with pkgs; {

    src = fetchFromGitHub {
      owner = "gnuradio";
      repo = "gnuradio";
      rev = "d9c981e5137f04a0a226d7b29d5814ecf53b2df2";
      sha256 = "1hl05xjxq9hkwv64ynlj72bnfrgzvxi7f9s6330qbik1vny9bi0n";
	  fetchSubmodules = true;
    };

    #preBuild = ''
	#'';
	preConfigure = ''
		export CCACHE_COMPRESS=1 CCACHE_BASEDIR=/tmp CCACHE_DIR=/nix/.ccache CCACHE_UMASK=002 CCACHE_MAXSIZE=5G
		ln -s ${ccache}/bin/ccache $CXX
		ln -s ${ccache}/bin/ccache $CPP
		ln -s ${ccache}/bin/ccache $CC
		export CXX=`pwd`/g++
		export CPP=`pwd`/g++
		export CC=`pwd`/gcc
		export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-unused-variable ${stdenv.lib.optionalString (!stdenv.isDarwin) "-std=c++11"}"
		sed -i 's/.*pygtk_version.*/set(PYGTK_FOUND TRUE)/g' grc/CMakeLists.txt
		find . -name "CMakeLists.txt" -exec sed -i '1iadd_compile_options($<$<COMPILE_LANGUAGE:CXX>:-std=c++11>)' "{}" ";"
	  '';

      propagatedBuildInputs = with python3Packages; [
            Mako numpy scipy matplotlib pyqt5 pyopengl
            pyaml
            sphinx
            lxml
            pygobject3
            pycairo
		    gtk3
		    gobjectIntrospection
		    (python3.withPackages (ps : with ps; [pygobject3]))
      ];
    cmakeFlags = [
        "-DENABLE_GR_FEC=OFF"
        "-DENABLE_GR_AUDIO=OFF"
        "-DENABLE_GR_VIDEO_SDL=OFF"
        #"-DCMAKE_BUILD_TYPE=Debug"
        ];
	  buildInputs = [
          cppzmq zeromq
          doxygen
	      wrapGAppsHook
		  gtk3
          gobjectIntrospection
          ccache
		  boost fftwFloat swig3 qt5.qtbase qwt6
		  pango.out
		  cairo
		  qwt SDL libusb1 uhd gsl log4cpp
		] ++ stdenv.lib.optionals stdenv.isLinux  [ alsaLib   ]
		  ++ stdenv.lib.optionals stdenv.isDarwin [ CoreAudio ];

	  postInstall = ''
		  printf "backend : Qt5Agg\n" > "$out/share/gnuradio/matplotlibrc"
		  for file in $(find $out/bin $out/share/gnuradio/examples -type f -executable); do
			  wrapProgram "$file" \
				  --prefix PYTHONPATH : $PYTHONPATH:$(toPythonPath "$out"):$out/lib/python3.6/dist-packages \
				  --set MATPLOTLIBRC "$out/share/gnuradio" \
				  ${stdenv.lib.optionalString stdenv.isDarwin "--set DYLD_FRAMEWORK_PATH /System/Library/Frameworks"}
		  done
		'';
	  });
        
in
gnuradio-with-packages
#pkgs.gnuradio-iio
