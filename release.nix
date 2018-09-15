{ nixpkgs ? (import ./nixpkgs.nix) } :
let
  pkgs_template = system: import nixpkgs {
	overlays=[(import ./demo3/gr-example/overlay.nix)];
    config={ inherit system;
  };};

  pkgs = pkgs_template "x86-linux";
  pkgs-arm = pkgs_template "armv7l-linux";

  job_template = sys:
           { system ? builtins.currentSystem }:
           (pkgs_template sys).callPackage
                 ./demo3/gr-example/derivation.nix {};

in
  {
    gnuradio-ex = job_template "x86_64-linux";
    gnuradio-ex-arm = job_template "armv7l-linux";
  }
