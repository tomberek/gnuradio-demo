# This file will allow development in nix-shell with python behaving correctly
# Load a gnuradio environment with python having packages correctly setup.

{nixpkgs ? (import ./nixpkgs.nix), withPythonPath ? true, ...}:
let
  pkgs = import nixpkgs {config ={}; overlays = [
    (import ../gr-example/overlay.nix)
  ];};

  gnuradio-with = with pkgs; gnuradio-with-packages.override ({
          extraPackages = [
            gtk-engine-murrine
            gnuradio-example];
          });

  grc = with pkgs; stdenv.mkDerivation rec {
    name = "grc";
    src = gnuradio;
    phases = ["installPhase"];
    buildInputs = [makeWrapper];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${gnuradio-with}/bin/gnuradio-companion \
                $out/bin/grc \
                --suffix GTK_PATH ':' "${gtk-engine-murrine}/lib/gtk-2.0" \
                --suffix GTK_MODULES ':' "${libcanberra_gtk2}/lib/gtk-2.0/modules/libcanberra-gtk-module.so"
    '';
  };

  output = with pkgs; stdenv.mkDerivation rec {
    name = "demo4-w";
    src = env;
    env = buildEnv {
      name = name;
      paths = buildInputs;
    };
    phases = ["installPhase"];
    installPhase = '' 
    ln -s $src $out
    '';
    nativeBuildInputs = [makeWrapper];
    buildInputs = [
        grc
        cmake cppunit boost
        ncurses
        zeromq
        uhd
        libcanberra_gtk2
        gnuradio-with
        (python.withPackages (ps: [
          ps.numpy ps.line_profiler ps.pyzmq 
          ps.requests
          pyexample
          pygnuradio
        ]))
        ];

  };
in
  output
