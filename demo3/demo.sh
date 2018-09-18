#!/usr/bin/env bash
echo "deleting"
RESULT=`readlink ./result`
rm ./result
nix-store -qR $RESULT | grep gnuradio | xargs nix-store --delete
echo "nix-build"
nix-build
read -p "[Hit Space]" -N 1 REPLY
echo "nix-store -qR ./result | grep gnuradio"
nix-store -qR ./result | grep gnuradio
