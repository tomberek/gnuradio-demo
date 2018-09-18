nix-store -q --references ../demo1/result
nix-store -q ../demo1/result --tree

cd nixpkgs-channels
git log
cd ..
nix show-derivation ./result | less
clear
echo "nix build"
read -p "[Enter]" -s -N 1
nix build
clear
echo "nix-shell -p gnuradio"
read -p "[Enter]" -s -N 1
NIX_PATH=nixpkgs=nixpkgs-channels nix-shell default.nix -A old
