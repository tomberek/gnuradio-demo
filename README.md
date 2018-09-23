# Demonstrations of Nix with GNURadio

## Install Nix

`curl https://nixos.org/nix/install | bash`

This will setup a single-user installation, it will require sudo to install to the following directories:

- `/nix` has the store, logs, and gcroots.
- `~/.nix-channels` has information about the channels you are subscribed to (similar to apt repository lists).
- `~/.nix-defexpr` has the channel information.
- `~/.nix-profile` has symlinks to your user environment.

The installation instructions should ask you to run: `. /home/$USER/.nix-profile/etc/profile.d/nix.sh`, it will add the nix environment to your path. You can disable Nix by removing this line from your `~/.profile`. You can uninstall Nix by removing line and above directories.

None of the following demos will overwrite any existing installations or libraries. If you wish to install anything to your path, `nix-env ./result` will do so. You can also run something like `nix-env -iA nixpkgs.hello` or in expanded form `nix-env --install --attr nixpkgs.hello`.

## Demo 0 - install hello

```
demo0
├── default.nix
└── demo.sh
```

`nix-build` only produces a local build of hello, but does not install it into your path.

## Demo 1 - install GNURadio

```
demo1
├── default.nix
└── demo.sh
```

The demo script will delete any existing result as well as clear it from the Nix store. Then GNURadio downloaded (from binary cache if available, or built from source) and a `result` symlink created pointing to its location in the store.

## Demo 2 - install two old versions of GNURadio

```
demo2
├── default.nix
└── demo.sh

```

`nix-build` will install two subsequent versions of GNURadio from 2016 using the exact dependencies and libraries that worked then.

## Demo 3 - add an OOT to GNURadio

```
demo3
├── default.nix
├── demo.sh
└── nixpkgs.nix
```

`default.nix` points to the gr-example at the root of the repo and adds it to GNURadio. This should reuse the GNURadio from demo2.

```
gr-example
├── apps
├── cmake
├── CMakeLists.txt
├── docs
├── examples
├── grc
├── include
├── lib
├── MANIFEST.md
├── arm.nix         # overrides the default to produce ARM builds, only if a remote builder is available
├── default.nix     # automatically used by nix-build or nix-env in a directory
├── derivation.nix  # provides the derivation description to build the OOT module
├── nixpkgs.nix     # provides a pinned snapshot of the Nixpks repository, for reproducibility
├── overlay.nix     # provides gnuradio-example
├── python
└── swig
```

The `*.nix` files provide the ability to track dependencies and correctly link everything together. Upon building gr-example with the right libraries, GNURadio is wrapped to include gr-example.

A CLI version can accomplish a similar thing:
```
nix-build -E '
with import <nixpkgs>{};
gnuradio-with-packages.override {
  extraPackages = [
    (import ../gr-example/default.nix{})
  ];
}'
```

## Demo 4 - Additional OOTs and refinements

Extras desired:
- Fix Gtk warnings
- Fix qt and Unity warnings
- Make it easier to get a nix-shell with all python packages available
- Add new OOTs

This one is a goes a bit farther, experimenting on ways to resolve some warnings by adding paths to the gnuradio-companion path. It also shows how to create additional sub-environments and make them available to a nix-shell environment, including OOTs and their libraries.

- TODO: determine what can/should be added to nixpkgs

## Demo 5 - Cross-compile ARM libraries using Ettus toolchain

- Still needs work, but can successfully overlay all the environments correctly
- TODO: cleanup
- TODO: remove CCACHE
- TODO: add to nixpkgs

## Demo 6 - GNURadio 3.8tech-preview

- Python3
- gtk3
- qt5
- pygobject3
- gobjectIntrospection
- TODO: update to use master
- TODO: add tech-preview to nixpkgs

## Demo 7 - libiio et. al. used with Pluto

- Newest nixpkgs needed for libiio
- TODO: update libiio with udev rules
- TODO: add libad9361-ad to nixpkgs
- TODO: add iio-oscilloscope to nixpkgs

## Demo 8 - Installer, ease of use

TODO: Look at modifying the Nix installer, cachix, and Dapptools to provide a simple installer people can use to directly install and/or run applications.
