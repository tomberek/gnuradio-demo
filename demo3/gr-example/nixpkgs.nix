let
  nixpkgs = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-18.09pre149190.fe6ebf85b76/nixexprs.tar.xz";
    sha256 = "02k88fija8qzyjalr1f2j57zhipyx3cs6gc5yibcqavxcchdkpnq";
  };
in nixpkgs
