
ifeq ("$(ARCHS)","normal")
	ARCHS = armv6 armv7 i386
endif

HAXE_BUILDS := $(ARCHS:%=build-haxe-%)

ifeq ("$(ACTION)","clean")
default: clean
else
default: $(HAXE_BUILDS)
endif

ifeq ("$(CONFIGURATION)","Debug")
   BUILD_STYLE := Debug
endif

default: debug_print

ifeq ("$(BUILD_STYLE)","Debug")
   DEBUG := -debug
   CONFIG := Debug
else
   DEBUG :=
   CONFIG := Release
endif

HAXE_OS := $(PLATFORM_NAME)
BUILD_TYPE := device
EXTRA_DEFINES :=
ifeq ("$(HAXE_OS)","iphonesimulator")
   HAXE_OS := iphonesim
   BUILD_TYPE := simulator
   EXTRA_DEFINES := -D simulator
endif
CONFIG := $(CONFIG)-$(HAXE_OS)

debug_print:
	@echo "Make $(HAXE_BUILDS)"

LIB_BASE := build/$(CONFIG)/::CPP_LIBPREFIX::ApplicationMain$(DEBUG)
LIB_DEST := $(DEBUG)/libApplicationMain.a
HAXE_ENV := export HAXEPATH="::ENV_HAXEPATH::"; export HAXE_STD_PATH="::ENV_HAXE_STD_PATH::"; export NEKOPATH="::ENV_NEKOPATH::"; export HAXELIB_PATH="$$(cd ../../../../Haxelib && pwd)"; export HXCPP_HOME="::ENV_HXCPP_HOME::"; export HXCPP_CONFIG="::ENV_HXCPP_CONFIG::"; export GEM_HOME="$$HOME/.gem"; export PATH="$$HAXEPATH:$$NEKOPATH:$$GEM_HOME/bin:$$PATH";

build-haxe-i386:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)-i386"
	$(HAXE_ENV) haxe Build.hxml $(EXTRA_DEFINES) -cpp build/$(CONFIG)-i386 $(DEBUG)
	$(HAXE_ENV) cd build/$(CONFIG)-i386; export HXCPP_NO_COLOR=1; haxelib run ::CPP_BUILD_LIBRARY:: Build.xml $(DEBUG) -options Options.txt
	cp build/$(CONFIG)-i386/::CPP_LIBPREFIX::ApplicationMain$(DEBUG).$(HAXE_OS).a ../lib/i386$(LIB_DEST)
	touch ../Classes/Main.mm

build-haxe-x86_64:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)-x86_64"
	$(HAXE_ENV) haxe Build.hxml $(EXTRA_DEFINES) -D HXCPP_M64 -cpp build/$(CONFIG)-x86_64 $(DEBUG)
	$(HAXE_ENV) cd build/$(CONFIG)-x86_64; export HXCPP_NO_COLOR=1; haxelib run ::CPP_BUILD_LIBRARY:: Build.xml $(DEBUG) -options Options.txt
	cp build/$(CONFIG)-x86_64/::CPP_LIBPREFIX::ApplicationMain$(DEBUG).$(HAXE_OS)-64.a ../lib/x86_64$(LIB_DEST)
	touch ../Classes/Main.mm

build-haxe-armv6:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)-armv6"
	$(HAXE_ENV) haxe Build.hxml $(EXTRA_DEFINES) -D HXCPP_ARMV6 -cpp build/$(CONFIG)-armv6 $(DEBUG)
	$(HAXE_ENV) cd build/$(CONFIG)-armv6; export HXCPP_NO_COLOR=1; haxelib run ::CPP_BUILD_LIBRARY:: Build.xml $(DEBUG) -options Options.txt
	cp build/$(CONFIG)-armv6/::CPP_LIBPREFIX::ApplicationMain$(DEBUG).$(HAXE_OS).a ../lib/armv6$(LIB_DEST)
	touch ../Classes/Main.mm

build-haxe-armv7:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)-armv7"
	$(HAXE_ENV) haxe Build.hxml $(EXTRA_DEFINES) -D HXCPP_ARMV7 -cpp build/$(CONFIG)-armv7 $(DEBUG)
	$(HAXE_ENV) cd build/$(CONFIG)-armv7; export HXCPP_NO_COLOR=1; haxelib run ::CPP_BUILD_LIBRARY:: Build.xml $(DEBUG) -options Options.txt
	cp build/$(CONFIG)-armv7/::CPP_LIBPREFIX::ApplicationMain$(DEBUG).$(HAXE_OS)-v7.a ../lib/armv7$(LIB_DEST)
	touch ../Classes/Main.mm

build-haxe-arm64:
	@echo "Haxe $(BUILD_TYPE) build: $(CONFIG)-arm64"
	$(HAXE_ENV) haxe Build.hxml $(EXTRA_DEFINES) -D HXCPP_ARM64 -cpp build/$(CONFIG)-arm64 $(DEBUG)
	$(HAXE_ENV) cd build/$(CONFIG)-arm64; export HXCPP_NO_COLOR=1; haxelib run ::CPP_BUILD_LIBRARY:: Build.xml $(DEBUG) -options Options.txt
	cp build/$(CONFIG)-arm64/::CPP_LIBPREFIX::ApplicationMain$(DEBUG).$(HAXE_OS)-64.a ../lib/arm64$(LIB_DEST)
	touch ../Classes/Main.mm

clean:
	rm -rf build
