{ nixpkgs ? <nixpkgs> }:
let
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ./overlay.nix)
    ];
  };

in pkgs.gnuradio-example
