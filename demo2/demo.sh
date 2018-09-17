nix-store -q --references ../demo1/result
nix-store -q ../demo1/result --tree

cd nixpkgs-channels
git log
cd ..
NIX_PATH=nixpkgs=nixpkgs-channels nix show-derivation nixpkgs.gnuradio | less
clear
echo "nix build nixpkgs.gnuradio"
read -p "[Enter]" -s -N 1
NIX_PATH=nixpkgs=nixpkgs-channels nix build nixpkgs.gnuradio
clear
echo "nix-shell -p gnuradio"
read -p "[Enter]" -s -N 1
NIX_PATH=nixpkgs=nixpkgs-channels nix-shell -p gnuradio
