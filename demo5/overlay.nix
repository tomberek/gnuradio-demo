self: super: rec {
  arm-src = builtins.fetchurl {
      url = "http://files.ettus.com/e3xx_images/e3xx-release-4/oecore-x86_64-armv7ahf-vfp-neon-toolchain-nodistro.0.sh";
      sha256= "0aid8sp18aj6c520f581hvzxs9pdvc8zdg2rp989xwyjxhdmb5as";
    };
  arm-env = super.stdenv.mkDerivation {
      name = "arm-env";
      src = arm-src;
      unpackPhase = ''
        pwd
      '';
      buildPhase = "";
      buildInputs = with super; [ stdenv which sudo python] ;
      installPhase = ''
        cp $src oecore.sh
        chmod +x oecore.sh
        mkdir $out
        ./oecore.sh -y -d $out
      '';
    };
  gnuradio = super.gnuradio.overrideAttrs (old:{
    buildInputs = with super; with super.pkgs; [
      boost fftw swig2 qt4
      qwt SDL libusb1 gr-ettus-env  gsl
      alsaLib
    ];

    configurePhase = ''
      mkdir build
      cd build

	  . ${arm-env}/environment-setup-armv7ahf-vfp-neon-oe-linux-gnueabi
      export CCACHE_COMPRESS=1 CCACHE_BASEDIR=/tmp CCACHE_DIR=/nix/.ccache CCACHE_UMASK=002 CCACHE_MAXSIZE=5G
      export CXX="${self.ccache}/bin/ccache $CXX"
      export CPP="${self.ccache}/bin/ccache $CPP"
      cmake .. -Wno-dev -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/oe-sdk_cross.cmake -DENABLE_GR_WXGUI=OFF -DENABLE_GR_VOCODER=OFF -DENABLE_GR_DTV=OFF -DENABLE_GR_ATSC=OFF -DENABLE_DOXYGEN=OFF -DCMAKE_INSTALL_PREFIX=$out -DPYTHON_EXECUTABLE:FILEPATH=${arm-env}/sysroots/x86_64-oesdk-linux/usr/bin/python2 -DPYTHON_LIBRARY:FILEPATH=${arm-env}/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi/usr/lib/libpython2.7.so -DPYTHON_INCLUDE_DIR:PATH=${arm-env}/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi/usr/include/python2.7
    '';
  });

  ########### GR-ETTUS
  uhd-env = super.buildEnv {
    name = "uhd-env";
    paths = [ uhd ];
    extraPrefix = "/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi/usr";
  };
  gr-ettus-env = super.buildEnv {
    name = "gr-ettus-env";
    paths = [ uhd-env arm-env ];
    ignoreCollisions = true;
    postBuild = ''
      pwd
      ls -alh
      echo out: $out
      '';
  };
  rfnoc-env = super.buildEnv {
    name = "rfnoc-env";
    paths = [ gr-ettus uhd gnuradio ];
  };
  gr-ettus = with super; with super.stdenv; mkDerivation {
    name = "gr-ettus";
    src = builtins.fetchGit {
      url = "https://github.com/EttusResearch/gr-ettus";
      ref = "master";
      rev = "51e88285b4147d97b45d5f49463a336501809dd1";
    };
    buildInputs = with super; with super.pkgs; [
      gnuradio boost gr-ettus-env
    ];

    preConfigure = ''
    '';
    dontUseCmakeConfigure = true;
    cmakeFlags = [
      "-DCMAKE_TOOLCHAIN_FILE=${gnuradio.src}/cmake/Toolchains/oe-sdk_cross.cmake"
      "-DCMAKE_INSTALL_PREFIX=$out"
    ];
    configurePhase = ''
      mkdir build
      cd build

      export PATH1="$PATH"
	  . ${gr-ettus-env}/environment-setup-armv7ahf-vfp-neon-oe-linux-gnueabi
      export CCACHE_COMPRESS=1 CCACHE_BASEDIR=/tmp CCACHE_DIR=/nix/.ccache CCACHE_UMASK=002 CCACHE_MAXSIZE=5G
      export CXX="${ccache}/bin/ccache $CXX"
      export CPP="${ccache}/bin/ccache $CPP"

      export PATH=${gr-ettus-env}/sysroots/x86_64-oesdk-linux/usr/bin:${gr-ettus-env}/sysroots/x86_64-oesdk-linux/usr/bin/arm-oe-linux-gnueabi:$PATH1
      export SDKTARGETSYSROOT=${gr-ettus-env}/sysroots/armv7ahf-vfp-neon-oe-linux-gnueabi
      export PKG_CONFIG_SYSROOT_DIR=$SDKTARGETSYSROOT
      export PKG_CONFIG_PATH=$SDKTARGETSYSROOT/lib/pkgconfig
      export CONFIG_SITE=$SDKTARGETSYSROOT
      export OECORE_TARGET_SYSROOT="$SDKTARGETSYSROOT"
      export LD="arm-oe-linux-gnueabi-ld  --sysroot=$SDKTARGETSYSROOT"
      export CONFIGURE_FLAGS="--target=arm-oe-linux-gnueabi --host=arm-oe-linux-gnueabi --build=x86_64-linux --with-libtool-sysroot=$SDKTARGETSYSROOT"
      export KCFLAGS="--sysroot=$SDKTARGETSYSROOT"

      # Append environment subscripts
      # Append environment subscripts
      if [ -d "$OECORE_TARGET_SYSROOT/environment-setup.d" ]; then
          for envfile in $OECORE_TARGET_SYSROOT/environment-setup.d/*.sh; do
              source $envfile
          done
      fi
      if [ -d "$OECORE_NATIVE_SYSROOT/environment-setup.d" ]; then
          for envfile in $OECORE_NATIVE_SYSROOT/environment-setup.d/*.sh; do
              source $envfile
          done
      fi
      cmake .. $cmakeFlags
    '';
  };

  ############# UHD
  uhd = with self; let 
    uhdImagesSrc = fetchurl {
      url = "https://github.com/EttusResearch/uhd/releases/download/v${version}/uhd-images_${images_version}.tar.xz";
      sha256 = "0y9i93z188ch0hdlkvv0k9m0k7vns7rbxaqsnk35xnlqlxxgqdvj";
    };
    version = "3.13.0.1";
    images_version = "3.13.0.1";
    in
      with self; stdenv.mkDerivation {
    name = "uhd-arm-${version}";
    
    src = builtins.fetchGit {
      url = "https://github.com/EttusResearch/uhd";
      ref = "rfnoc-devel";
      rev = "eec24d7b0442616fdbe9adf6b426959677e67f92";
    };
    buildInputs = [ coreutils cmake ];

	configurePhase = "echo skip configure";
	buildPhase = "echo skip build";
    cmakeFlags = [
     "-DCMAKE_CROSSCOMPILING=ON"
     "-DCMAKE_TOOLCHAIN_FILE=../host/cmake/Toolchains/oe-sdk_cross.cmake"
     "-DCMAKE_INSTALL_PREFIX=/"
     "-DENABLE_OCTOCLOCK=OFF"
     "-DENABLE_DOXYGEN=OFF"
     "-DENABLE_N230=OFF"
     "-DENABLE_USRP1=OFF"
     "-DENABLE_USRP2=OFF"
     "-DENABLE_N230=OFF"
     "-DENABLE_X300=OFF"
     "-DENABLE_B100=OFF"
     "-DENABLE_EXAMPLES=OFF"
     "-DENABLE_MAN_PAGES=OFF"
     "-DENABLE_MANUAL=OFF"
     "-DENABLE_UTILS=ON"
     "-DENABLE_MPMD=OFF"
     "-DENABLE_TESTS=OFF"
     "-DENABLE_GPSD=OFF"
     "-DENABLE_E300=ON"
     "-DENABLE_STATIC_LIBS=OFF"
     "-DENABLE_B200=OFF"
     "-DENABLE_USB=ON"
     "-DENABLE_LIBUHD=ON"
	];
    #patches = ./neon.patch;

    postPhases = [ "installFirmware" ];
    installFirmware = ''
      mkdir -p "$out/share/uhd/images"
      tar --strip-components=1 -xvf "${uhdImagesSrc}" -C "$out/share/uhd/images"
      find $out/share/uhd/images -type f -not -name "usrp_e3*" -exec rm {} \;
    '';
    hostSystem = "armv7l-linux-gnueabihf";
    preFixup = ''
      echo strip libraries...
      find $out -iname "*.so*" -type f | xargs arm-oe-linux-gnueabi-strip --strip-unneeded
    '';
	installPhase = ''
		mkdir -p $out
		mkdir -p host/build
		cd host/build
		. ${arm-env}/environment-setup-armv7ahf-vfp-neon-oe-linux-gnueabi

        export CCACHE_COMPRESS=1 CCACHE_BASEDIR=/tmp CCACHE_DIR=/nix/.ccache CCACHE_UMASK=002 CCACHE_MAXSIZE=5G
        export CXX="${ccache}/bin/ccache $CXX"
        export CPP="${ccache}/bin/ccache $CPP"


		cmake .. $cmakeFlags
		make -j4
		make install DESTDIR=$out
		'';
    };
    meta = with super.stdenv.lib; {
        description = "USRP Hardware Driver (for Software Defined Radio)";
        longDescription = ''
          The USRP Hardware Driver (UHD) software is the hardware driver for all
          USRP (Universal Software Radio Peripheral) devices.

          USRP devices are designed and sold by Ettus Research, LLC and its parent
          company, National Instruments.
        '';
        homepage = https://uhd.ettus.com/;
        license = licenses.gpl3Plus;
        platforms = platforms.linux;
        maintainers = with maintainers; [ bjornfor fpletz tomberek ];
    };
}
