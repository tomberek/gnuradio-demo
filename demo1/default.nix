# To update, visit https://nixos.org/channels/nixpkgs-unstable
let
  nixpkgs = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-18.09pre147772.d1ae60cbad7/nixexprs.tar.xz";
    sha256 = "178vva8wxiy4lkpz2sdi7a9s92fdrmfg2ch5b0rbd24pxpv4xbrb";
  };
  pkgs = import nixpkgs {};
in
  pkgs.gnuradio
