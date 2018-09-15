{ nixpkgs ? (import ./nixpkgs.nix), ... } :
let
  pkgs = import nixpkgs {
	overlays=[
	  (import ./demo3/gr-example/overlay.nix)
	];
	config={};};
  pkgs-arm = import nixpkgs {
	overlays=[
	  (import ./demo3/gr-example/overlay.nix)
	];
	config={};
	system="armv7l-linux";
  };

  nixBuild = drv : extraAttrs :drv.overrideAttrs (old:{
    initPhase = ''
      mkdir -p $out/nix-support
      echo "$system" > $out/nix-support/system
    '';
    prePhases  = ["initPhase"] ++ (if builtins.hasAttr "prePhases" old then old.prePhases else []);
    postPhases = (if builtins.hasAttr "postPhases" old then old.postPhases else []) ++ ["finalPhase"];
    finalPhase = ''
      if test -e $src/nix-support/hydra-release-name; then
        cp $src/nix-support/hydra-release-name $out/nix-support/hydra-release-name
      fi
    '';
  }//extraAttrs);

  jobs = rec {

    gnuradio-ex = { system ? builtins.currentSystem }:
    (pkgs.callPackage ./demo3/gr-example/derivation.nix {});

    gnuradio-ex-arm = { system ? builtins.currentSystem }:
    (pkgs-arm.callPackage ./demo3/gr-example/derivation.nix {});

    gnuradio-example = { system ? builtins.currentSystem }:
      nixBuild (pkgs.callPackage ./demo3/gr-example/derivation.nix {}){};

    gnuradio-example-arm = { system ? builtins.currentSystem }:
      nixBuild (pkgs-arm.callPackage ./demo3/gr-example/derivation.nix {
      }){
        system = "armv7l-linux";
      };


    };
in
  jobs
    /*
    nix-build = { system ? builtins.currentSystem }: nixBuild (pkgs.callPackage ./derivation.nix {}) {};
    nix-build-arm = { system ? builtins.currentSystem }: with pkgs-arm; (nixBuild (pkgs-arm.callPackage ./derivation.nix {
      stdenv = pkgs-arm.stdenv;
      system = "armv7l-linux";
    }) {});

  };
*/
