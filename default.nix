# This nix file will load the overlay and build the example OOT module
{ nixpkgs ? (import ./nixpkgs.nix) }:
let
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ./overlays/overlay.nix)
    ];
  };
in with pkgs;

  gnuradio-with-packages.override ({
    extraPackages = [
      gnuradio-example
    ];
  })
