# Makefile for mdns-repeater


ZIP_NAME = mdns-repeater-$(VCSVERSION)

ZIP_FILES = mdns-repeater	\
			README.txt		\
			LICENSE.txt

VCSVERSION=$(shell git describe --dirty="-SNAPSHOT" --always --tags)

CFLAGS=-Wall

ifdef DEBUG
CFLAGS+= -g
else
CFLAGS+= -Os
LDFLAGS+= -s
endif

CFLAGS+= -DVCSVERSION="\"${VCSVERSION}\""

.PHONY: all clean

all: mdns-repeater

mdns-repeater.o: _version

mdns-repeater: mdns-repeater.o

.PHONY: zip
zip: TMPDIR := $(shell mktemp -d)
zip: mdns-repeater
	mkdir $(TMPDIR)/$(ZIP_NAME)
	cp $(ZIP_FILES) $(TMPDIR)/$(ZIP_NAME)
	-$(RM) $(CURDIR)/$(ZIP_NAME).zip
	cd $(TMPDIR) && zip -r $(CURDIR)/$(ZIP_NAME).zip $(ZIP_NAME)
	-$(RM) -rf $(TMPDIR)

# version checking rules
.PHONY: dummy
_version: dummy
	@echo $(VCSVERSION) | cmp -s $@ - || echo $(VCSVERSION) > $@

clean:
	-$(RM) *.o
	-$(RM) _version
	-$(RM) mdns-repeater
	-$(RM) mdns-repeater-*.zip
	-$(RM) build-stamp
	-$(RM) -rf debian/mdns-repeater

install:
	install -d $(DESTDIR)/usr/sbin
	install -d $(DESTDIR)/lib/systemd/system
	install -d $(DESTDIR)/etc/default
	install -m 0755 mdns-repeater $(DESTDIR)/usr/sbin
	install -m 0644 mdns-repeater.service $(DESTDIR)/lib/systemd/system
	install -m 0644 mdns-repeater.default $(DESTDIR)/etc/default/mdns-repeater