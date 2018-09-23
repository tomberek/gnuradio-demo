#!/usr/bin/env bash
NIX_PATH=nixpkgs=/home/dev/nixpkgs:nixpkgs-overlays=./overlays/ nix-build '<nixpkgs>' -A iio-oscilloscope -o osc

