{nixpkgs ? <nixpkgs> }:
let
  pkgs = import nixpkgs {
    config ={};
    overlays = [
      (import ../gr-example/overlay.nix)
    ];
  };

in with pkgs;

gnuradio-with-packages.override ({
      extraPackages = [
          gnuradio-example];
      })
