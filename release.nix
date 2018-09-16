{ nixpkgs ? (import ./nixpkgs.nix) } :
let
  pkgs_template = system: import nixpkgs {
    overlays=[
      (import ./demo3/gr-example/overlay.nix)
      (import ./orc.nix)
    ];
    config={};
    inherit system;
  };

  job_template = sys:
     { system ? sys }:
       (pkgs_template sys).gnuradio-example.overrideAttrs
         (old: {
           system = sys;
         });

in
  {
    gnuradio-ex = job_template "x86_64-linux";
    gnuradio-ex-arm = job_template "armv7l-linux";
  }
