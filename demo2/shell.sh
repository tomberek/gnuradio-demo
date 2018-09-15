#! /bin/sh -eu

# make gcroot for each dependency of shell and run nix-shell

mkdir -p .gcroots
echo 1
NIX_PATH=nixpkgs=nixpkgs-channels nix-instantiate --indirect --add-root $PWD/.gcroots/shell.drv
echo 2
NIX_PATH=nixpkgs=nixpkgs-channels nix-store --indirect --add-root $PWD/.gcroots/shell.dep --realise $(nix-store --query --references $PWD/.gcroots/shell.drv)
echo 3
NIX_PATH=nixpkgs=nixpkgs-channels exec nix-shell $(readlink $PWD/.gcroots/shell.drv)
