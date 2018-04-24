# This nix file will load the overlay and build the example OOT module
{ nixpkgs ? (import ./nixpkgs.nix) }:
let
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ./overlays/gnuradio-oot.nix)
    ];
  };
in
  pkgs.gnuradio-example