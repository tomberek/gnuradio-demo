let
  self = import <nixpkgs>{};
  nix-bundle_src = self.fetchFromGitHub {
      owner = "tomberek";
      repo = "nix-bundle";
      rev = "e5e01ff63ec1840b7d0a1af1ed4d6ce49711f389";
      sha256 = "0swh0gnnvf0gg8v5l7pm4lf7qvdfp3chl3vq5bzfkzq6bsn42nnz";
  };
  nixpkgs_src_musl = self.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b1ed0b04817828141ee6ffc8ee66800fd19fc777";
    sha256 = "0jxmrma3vp71wqav2jwwn2sxi67j1qdci1zcj7lagbzn7v05792f";
  };
  appimage_src = drv : exec : with self;
    self.stdenv.mkDerivation rec {
      name = drv.name + "-appdir";
      env = buildEnv {
        inherit name;
        paths = buildInputs;
      };
      src = env;
      inherit exec;
      buildInputs = [ drv ];
      buildCommand = ''
        source $stdenv/setup
        mkdir -p $out/bin
        cp -rL ${drv}/* $out/
        chmod +w -R $out/

        mkdir -p $out/share/icons
        touch $out/share/icons/${drv.name}.png

        mkdir -p $out/share/applications
        cat <<EOF > $out/share/applications/${drv.name}.desktop
        [Desktop Entry]
        Type=Application
        Version=1.0
        Name=${drv.name}
        Path=${exec}
        Icon=$out/share/icons/${drv.name}
        Exec=$exec
        Terminal=true
        EOF
        chmod +w -R $out/
        '';
        system = builtins.currentSystem;
  };
  grc = with self; stdenv.mkDerivation rec {
    name = "grc";
    src = gnuradio;
    phases = ["installPhase"];
    buildInputs = [ (python-setup-hook "lib/python2.7/site-packages") makeWrapper hicolor-icon-theme ];
    usr_fonts = buildEnv {
      name = "fonts";
      paths = [noto-fonts];
    };
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/fonts
      cp ${usr_fonts}/share/fonts/* $out/share/fonts -R

      makeWrapper ${gnuradio}/bin/gnuradio-companion \
        $out/bin/grc \
        --suffix GTK_PATH ':' "${gtk-engine-murrine}/lib/gtk-2.0" \
        --suffix GTK_MODULES ':' "${libcanberra_gtk2}/lib/gtk-2.0/modules/libcanberra-gtk-module.so"
    '';
  };
in
  with (import (nix-bundle_src + "/appimage-top.nix"){nixpkgs' = nixpkgs_src_musl;});
    appimage (appdir {
      name ="gnuradio";
      target = appimage_src grc "/bin/grc";
    })

