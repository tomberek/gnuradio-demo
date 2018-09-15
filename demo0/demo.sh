#/usr/bin/env bash
grep --color -H '' default.nix
read -p "[Hit Space]" -N 1 REPLY
cat <<EOF
#
# These are equivalent because default.nix specifies nixpkgs.hello
nix build nixpkgs.hello
nix build
#
#
#
# 1) nix build
EOF
read -p "[Hit Space]" -N 1 REPLY
nix build
ls -al
cat <<EOF
#
#
#
# 2) nix build nixpkgs.hello
EOF
read -p "[Hit Space]" -N 1 REPLY
nix build nixpkgs.hello
ls -al
