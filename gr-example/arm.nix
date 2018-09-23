let
  #nixpkgs = import ./nixpkgs.nix;
  nixpkgs = <nixpkgs>;
  pkgs = import nixpkgs {
    config = {};
    system = "armv7l-linux";
    overlays = [
      (import ./overlay.nix)
    ];
  };

in pkgs.gnuradio-example
