# To update, visit https://nixos.org/channels/nixpkgs-unstable
{ nixpkgs ? <nixpkgs>}:
let
  nixpkgs_predefined = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-18.09pre147772.d1ae60cbad7/nixexprs.tar.xz";
    sha256 = "178vva8wxiy4lkpz2sdi7a9s92fdrmfg2ch5b0rbd24pxpv4xbrb";
  };
  pkgs = import nixpkgs {
    overlays = [(
      self: super: {
        gnuradio = super.gnuradio.overrideAttrs (old: rec {
          version = "3.7.13.4";
          name = "gnuradio-${version}";
          src = self.fetchFromGitHub {
            owner = "gnuradio";
            repo = "gnuradio";
            rev = "v${version}";
            sha256 = "0ybfn2zfr9lc1bi3c794l4bzpj8y6vas9c4rbcj4nqlx0zf3p8fn";
            fetchSubmodules = true;
          };
          preBuild = ''
            echo hi
          '';

        });
      }
    )];
  };
in
  pkgs.gnuradio
