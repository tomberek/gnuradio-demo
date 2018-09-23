self: super: {
  libad9361-iio = super.callPackage ../default.nix{};
  iio-oscilloscope = super.callPackage ../osci.nix{};
  libiio = super.libiio.overrideAttrs (old:{
    buildInputs = old.buildInputs ++ [ self.libusb1];
    cmakeFlags = [
      # "-DINSTALL_UDEV_RULE=NO"
      "-DUDEV_RULES_INSTALL_DIR=$out/etc/udev/rules.d"
    ];
  });
}
