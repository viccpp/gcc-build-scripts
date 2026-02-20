# GCC build script

VER = 15.2
prefix = /opt

GCC := gcc-$(VER).0
GMP  = gmp-6.2.1
ISL  = isl-0.24
MPC  = mpc-1.3.0
MPFR = mpfr-4.2.0

GCC_TAR := $(GCC).tar.xz
GMP_TAR := $(GMP).tar.xz
ISL_TAR := $(ISL).tar.xz
MPC_TAR := $(MPC).tar.gz
MPFR_TAR := $(MPFR).tar.xz

WGET = wget

.PHONY: configure build install clean distclean

build: _build/Makefile
	cd _build && $(MAKE) -j`nproc`

configure: _build/Makefile ;

_build/Makefile: $(GCC)/configure $(foreach f,gmp isl mpc mpfr, $(GCC)/$(f)/configure)
	[ -d _build ] || mkdir _build
	cd _build && ../$(GCC)/configure \
		--prefix=$(prefix)/gcc-$(VER) --enable-languages=c,c++ \
		--disable-multilib --disable-libstdcxx-pch --enable-lto

$(GCC)/gmp/configure: $(GMP_TAR) $(GCC)/configure
	tar xf $(GMP_TAR) && mv $(GMP) $(GCC)/gmp && touch $@

$(GCC)/isl/configure: $(ISL_TAR) $(GCC)/configure
	tar xf $(ISL_TAR) && mv $(ISL) $(GCC)/isl && touch $@

$(GCC)/mpc/configure: $(MPC_TAR) $(GCC)/configure
	tar xf $(MPC_TAR) && mv $(MPC) $(GCC)/mpc && touch $@

$(GCC)/mpfr/configure: $(MPFR_TAR) $(GCC)/configure
	tar xf $(MPFR_TAR) && mv $(MPFR) $(GCC)/mpfr && touch $@

$(GCC)/configure: $(GCC_TAR)
	tar xf $< && touch $@

# https://gcc.gnu.org/mirrors.html
$(GCC_TAR):
	$(WGET) https://ftp.gnu.org/gnu/gcc/$(GCC)/$@

# https://gmplib.org/
$(GMP_TAR):
	$(WGET) https://gmplib.org/download/gmp/$@

# https://libisl.sourceforge.io/
$(ISL_TAR):
	$(WGET) https://libisl.sourceforge.io/$@

# https://www.multiprecision.org/mpc/download.html
$(MPC_TAR):
	$(WGET) https://www.multiprecision.org/downloads/$@

# https://www.mpfr.org/mpfr-current
$(MPFR_TAR):
	$(WGET) https://www.mpfr.org/$(MPFR)/$@

install:
	cd _build && make install-strip

distclean: clean
	-rm -rf *.tar.?z

clean:
	-rm -rf _build $(GCC)
