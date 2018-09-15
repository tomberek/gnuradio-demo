let
  # nixpkgs = import ./nixpkgs.nix;
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ./overlay.nix)
    ];
  };

in pkgs.gnuradio-example
