# This file will allow development in nix-shell with python behaving correctly
# Load a gnuradio environment with python having packages correctly setup.

{nixpkgs ? (
<nixpkgs>
#import ./nixpkgs.nix
)
, withPythonPath ? true, ...}:

let
  pkgs = import nixpkgs {config ={}; overlays = [
    (import ../demo7/overlays/overlay.nix)
    (import ../demo4/overlay/overlay.nix)
    (import ../gr-example/overlay.nix)
    (import ../gr-iio/overlay.nix)
  ];};

  gnuradio-with = with pkgs; gnuradio-with-packages.override ({
    extraPackages = [
      libiio
      gnuradio-example
      gnuradio-iio
      ];
    });

  grc = with pkgs; stdenv.mkDerivation rec {
    name = "grc";
    src = gnuradio-with;
    phases = ["installPhase"];
    buildInputs = [ (python-setup-hook "lib/python2.7/site-packages") makeWrapper];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${gnuradio-with}/bin/gnuradio-companion \
        $out/bin/grc \
        --suffix GTK_PATH ':' "${gtk-engine-murrine}/lib/gtk-2.0" \
        --suffix GTK_MODULES ':' "${libcanberra_gtk2}/lib/gtk-2.0/modules/libcanberra-gtk-module.so"
    '';
  };

  python-env = pkgs.python.buildEnv.override {
    ignoreCollisions = true;
    extraLibs = with pkgs; with pkgs.pythonPackages; [
      matplotlib numpy line_profiler pyzmq 
      ipython pyqt5
      gnuradio-example
      gnuradio-iio
      (pkgs.pythonPackages.toPythonModule gnuradio)
    ];
  };
  output = with pkgs; stdenv.mkDerivation rec {
    name = "output";
    src = env;
    env = buildEnv {
      name = name;
      paths = buildInputs;
      ignoreCollisions = true;
    };
    builder = builtins.toFile "builder.sh" ''
        source $stdenv/setup; ln -s $env $out
    '';
    buildInputs = [
      makeWrapper
      alsaLib
      cmake cppunit boost
      ncurses
      grc
      python-env
      qt4
      libunity
    ];
  };
in
  #grc
  output
  #gnuradio-with
