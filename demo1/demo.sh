#/usr/bin/env bash
grep --color -H '' default.nix
read -p "[Hit Space]" -N 1 REPLY
echo "nix-build"
nix-build

