self: super:
rec {
  gnuradio-example = self.callPackage ./derivation.nix {};

  python-example = super.buildEnv {
    name = "python-example";
    paths = [pyexample pygnuradio];
  };
  pyexample = super.pythonPackages.buildPythonPackage rec {
    preferLocalBuild = true;
    name = "pygnuradio";
    src = gnuradio-example;
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
