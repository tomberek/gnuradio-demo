# This file will allow development in nix-shell with python behaving correctly
# Load a gnuradio environment with python having packages correctly setup.

{nixpkgs ? (import ./nixpkgs.nix), withPythonPath ? true, ...}:
let
  pkgs = import nixpkgs {config ={}; overlays = [
    (import ./overlays/overlay.nix)
  ];};
in
with pkgs.python27Packages;
pkgs.python27Packages.buildPythonPackage rec {
  name = "gnuradioEnv";
  env = pkgs.buildEnv { name = name; paths = buildInputs; };
  src = ./. ;
  buildInputs = with pkgs; [nix.out];
  propagatedBuildInputs = with pkgs; [
    (python.withPackages (ps: [ps.numpy ps.line_profiler ps.pyzmq pygnuradio ]))
    cmake cppunit boost
    numpy
    ncurses
    zeromq
    uhd
    gnuradio-example
  ];
}
