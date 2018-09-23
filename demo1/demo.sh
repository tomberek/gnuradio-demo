#/usr/bin/env bash
clear
grep --color -H '' default.nix
read -p "[Hit Space]" -N 1 REPLY
RESULT=`readlink result`
echo "nix-store --delete $RESULT"
rm ./result && nix-store --delete $RESULT
read -p "[Hit Space]" -N 1 REPLY
echo "nix build"
nix build

