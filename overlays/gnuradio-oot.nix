self: super:
rec {
  gnuradio-example = self.callPackage ./pkgs/gnuradio-example.nix {};

  python-with-gnuradio = self.python.withPackages (ps : [ps.numpy ps.line_profiler pygnuradio ]);
  pygnuradio = super.pythonPackages.buildPythonPackage rec {
    preferLocalBuild = true;
    name = "pygnuradio";
    src = self.gnuradio;
    doCheck = false;
    format = "other";
    installPhase = ''
      mkdir $out
      cp -R lib $out/lib
      cp -R include $out/include
      cp -R share $out/share
      '';
    preBuild = ''
      touch setup.py
    '';
  };
}
