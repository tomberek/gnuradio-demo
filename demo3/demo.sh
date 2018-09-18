#!/usr/bin/env bash
echo "nix-store -qR ./result | grep gnuradio"
nix-store -qR ./result | grep gnuradio
