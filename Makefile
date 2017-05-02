PROG ?= genphrase
PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
SYSTEM_EXTENSION_DIR ?= $(LIBDIR)/password-store/extensions
MANDIR ?= $(PREFIX)/share/man
GLOBAL_EXT_DIR = $(DESTDIR)$(SYSTEM_EXTENSION_DIR)
GLOBAL_EXT_DIR_RESOURCES = $(GLOBAL_EXT_DIR)/$(PROG)-resources
ifdef PASSWORD_STORE_EXTENSIONS_DIR
    LOCAL_EXT_DIR = $(PASSWORD_STORE_EXTENSIONS_DIR)
else
    ifdef PASSWORD_STORE_DIR
        LOCAL_EXT_DIR = $(PASSWORD_STORE_DIR)/.extensions
    else
        LOCAL_EXT_DIR = $(HOME)/.password-store/.extensions
    endif
endif
LOCAL_EXT_DIR_RESOURCES = $(LOCAL_EXT_DIR)/$(PROG)-resources

all:
	@echo "pass-$(PROG) are scripts and plain-text files, and no compilation is needed."
	@echo ""
	@echo "To run pass-$(PROG) the following tools must be present on the system:"
	@echo "    pass (Password Store)"
	@echo "    Python (version 2.7 or 3.x)"
	@echo ""
	@echo "Please read the file INSTALL for more information."
	@echo ""
	@echo "To install locally for the current user (recommended), type \`make install'."
	@echo ""
	@echo "To install system-wide, type \`make globalinstall'."

globalinstall:
	install -v -d "$(DESTDIR)$(MANDIR)/man1"
	install -m0644 -v pass-$(PROG).1 "$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
	install -v -d "$(GLOBAL_EXT_DIR)"
	install -m0755 $(PROG).bash "$(GLOBAL_EXT_DIR)/$(PROG).bash"
	install -v -d "$(GLOBAL_EXT_DIR_RESOURCES)"
	install -m0755 "$(PROG)-resources/_phrase.py" "$(GLOBAL_EXT_DIR_RESOURCES)/_phrase.py"
	install -m0444 "$(PROG)-resources/eff_large_wordlist.txt" "$(GLOBAL_EXT_DIR_RESOURCES)/eff_large_wordlist.txt"

globaluninstall:
	rm -rf "$(DESTDIR)$(MANDIR)/man1/pass-$(PROG).1"
	rm -rf "$(GLOBAL_EXT_DIR_RESOURCES)"
	rm -rf "$(GLOBAL_EXT_DIR)/$(PROG).bash"

install:
	install -v -d "$(LOCAL_EXT_DIR)"
	install -m0755 $(PROG).bash "$(LOCAL_EXT_DIR)/$(PROG).bash"
	install -v -d "$(LOCAL_EXT_DIR_RESOURCES)"
	install -m0755 "$(PROG)-resources/_phrase.py" "$(LOCAL_EXT_DIR_RESOURCES)/_phrase.py"
	install -m0444 "$(PROG)-resources/eff_large_wordlist.txt" "$(LOCAL_EXT_DIR_RESOURCES)/eff_large_wordlist.txt"

uninstall:
	rm -rf "$(LOCAL_EXT_DIR_RESOURCES)"
	rm -rf "$(LOCAL_EXT_DIR)/$(PROG).bash"

test:
	$(MAKE) -C tests

doc: README

README: pass-genphrase.1
	echo '[![Build Status](https://travis-ci.org/congma/pass-genphrase.svg?branch=master)](https://travis-ci.org/congma/pass-genphrase)' > README
	echo >> README
	groff -m mandoc -T ascii pass-genphrase.1 | col -bx >> README

.PHONY: install globalinstall uninstall globaluninstall test
