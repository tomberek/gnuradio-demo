# This file pins nixpkgs to a specific version.
# To update use: nix-prefetch-url unpack <URL-TO-NIXPKGS>
# and replace url and sha256 as needed
let
  nixpkgs = builtins.fetchTarball {
    url = "https://d3g5gsiof5omrk.cloudfront.net/nixos/18.03/nixos-18.03.132008.ad771371fb2/nixexprs.tar.xz";
    sha256 = "0kkvbglvjc3qw3170dcy18vq7fj6q0n7liir6vfymjgwb0vdmina";
  };
in nixpkgs
