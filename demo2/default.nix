let
  nixpkgs_1 = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "993dadd2136ffca9a6f81d7e4d6acd5116da83a0";
  };
  nixpkgs_2 = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "74883be684140fb691992a415bda87595a1b6a7b";
  };
  #pkgs = import ./nixpkgs-channels {};
  pkgs_1 = import nixpkgs_1 {};
  pkgs_2 = import nixpkgs_2 {};
  output = {

    old=pkgs_1.gnuradio;
    new=pkgs_2.gnuradio;
  };
in
  output
