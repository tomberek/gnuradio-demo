#/usr/bin/env bash
grep --color -H '' default.nix
read -p "[Hit Space]" -N 1 REPLY
cat <<EOF

# These are equivalent because default.nix specifies nixpkgs.hello
nix-env -iA nixpkgs.hello
nix-build
EOF
read -p "" -N 1 REPLY
nix-build
