# These options are primarily to isolate GNU Radio from impurities
.DEFAULT_GOAL := default
NIXPKGS_FETCH = $(shell nix-instantiate --eval nixpkgs.nix | tr -d '"')
NIX_PATH = nixpkgs-overlays=${CURDIR}/overlays:nixpkgs=${NIXPKGS_FETCH}:.
GRC_BLOCKS_PATH := ${CURDIR}:${GRC_BLOCKS_PATH}
GRC_HIER_PATH := ${CURDIR}
PYTHONPATH := ${CURDIR}:${PYTHONPATH}
APPDATA := $(CURDIR)
TMPDIR := ${CURDIR}
prefix ?= ${CURDIR}
NIX_OPTIONS := $(if $(FAST),--option binary-caches '' --option trusted-binary-caches '',${NIX_OPTIONS})

# Primary uses:
# `make help` print help statements for this makefile
# `make` will run grcc
# `make run` will run a flowgraph
# `make dev` creates a dev-shell
# `make job-*` will run various hydra jobs locally

.install-nix-2.0:
	curl -o .install-nix-2.0 https://nixos.org/nix/install
	curl -o .install-nix-2.0.sig https://nixos.org/nix/install.sig
	touch .install-nix-2.0

# TODO: The source line may fail on MAC, see README...apparently this also happens on a fresh Ubuntu install
.install-nix-2.0.run: | .install-nix-2.0
	sh ./.install-nix-2.0
	echo "You may need to restart your shell."
	touch .install-nix-2.0.run

dev: ## Places you into a developement shell
	$(call stanza,$(call nix_shell,--command,return))
shell: dev

grc: .install-nix-2.0.run ## Starts GNU Radio Companion with the right libraries
	$(call stanza,$(call nix_shell,--command,\
	export GRC_BLOCKS_PATH=$$(type -p gnuradio-companion)/grc/blocks ; \
	$(call make_grc_home,gnuradio-companion) ))
	chmod +w .

clean: ## Clean up repo
	rm -rf .gnuradio .gr_fftw_wisdom*

default: grc
.PHONY: clean dev grc help
help: ## Print this help
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Makefile magic to allow multiline expansion of the "check" and "intallcheck" rules
empty :=
tab := ${empty}	
define \n :=


endef
stanza = $(subst ${\n}, \${\n}${tab},$1)

# Use APPDATA and chmod to fool gnuradio into limiting filesystem pollution
# Remove home when trying to create sandbox build
# Also create vmcircbuf of the right kind for the OS (Linux/OSX)
# export GRC_BLOCKS_PATH=`echo $$GRC_BLOCKS_PATH | tr ':' "\n" | sort -u | tr "\n" ':'` ;
define make_grc_home =
finish(){ chmod +w ${APPDATA} ; rm -rf ${APPDATA}/.gnuradio ; } ;
export GRC_HIER_PATH=$$GRC_HIER_PATH ;
set -e ;
trap finish EXIT INT HUP ERR ;
chmod +w ${APPDATA} ;
mkdir -p ${APPDATA}/.gnuradio/prefs ;
chmod -w ${APPDATA} ;
export GR_FACTORY="gr::vmcircbuf_$$( [ "$$(uname -s)" = "Linux" ] && echo "sysv_shm" || echo "mmap_tmpfile")_factory0" ;
echo $$GR_FACTORY > ${APPDATA}/.gnuradio/prefs/vmcircbuf_default_factory ;
unset HOME ;
export APPDATA=${APPDATA} ;
$1
endef

# Ensure GRC places output into ./. , then start a shell
# GTK variables are to remove warnings
define nix_shell =
if [ -z "$$NIX_ENFORCE_NO_NATIVE" ] ; then
	nix-shell --pure --show-trace $1 '
		export GTK_PATH=${GTK_PATH}:~/.nix-profile/lib/gtk-2.0 ;
		export GTK2_RC_FILES=${GTK2_RC_FILES}:~/.nix-profile/share/themes/oxygen-gtk/gtk-2.0/gtkrc ;
		export NIX_PATH=${NIX_PATH}:$$NIX_PATH ;
		export GRC_HIER_PATH=${GRC_HIER_PATH} ;
		export TMPDIR=${TMPDIR} ;
		$2 ' ;
else
	$2 ;
fi
endef
