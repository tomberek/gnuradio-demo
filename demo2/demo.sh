nix-store -q --references /nix/store/54i5wv0n7864g0vsyj7msiyfh3f53mww-gnuradio-3.7.1.drv
read -p "[Enter]" -s -N 1
nix-store -q /nix/store/54i5wv0n7864g0vsyj7msiyfh3f53mww-gnuradio-3.7.1.drv --tree
NIX_PATH=nixpkgs=nixpkgs-channels nix show-derivation nixpkgs.gnuradio | less
NIX_PATH=nixpkgs=nixpkgs-channels nix build nixpkgs.gnuradio
NIX_PATH=nixpkgs=nixpkgs-channels nix-shell -p gnuradio

