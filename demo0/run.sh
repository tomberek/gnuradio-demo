#/usr/bin/env bash
set -x

# These are equivalent because default.nix specifies nixpkgs.hello
nix-env -iA nixpkgs.hello
nix-build
