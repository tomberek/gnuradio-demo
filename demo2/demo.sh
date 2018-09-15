nix-store -q --references ../demo1/result
read -p "[Enter]" -s -N 1
nix-store -q ../demo1/result --tree

cd nixpkgs-channels
git log
cd ..
NIX_PATH=nixpkgs=nixpkgs-channels nix show-derivation nixpkgs.gnuradio | less
NIX_PATH=nixpkgs=nixpkgs-channels nix build nixpkgs.gnuradio
NIX_PATH=nixpkgs=nixpkgs-channels nix-shell -p gnuradio
