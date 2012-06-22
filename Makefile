# App info
APPNAME = bluelog
VERSION = 1.0.4

# Bluelog-specific, select which CSS theme to use as default
# Options: digifail.css, backtrack.css, pwnplug.css, openwrt.css
DEFAULT_CSS = digifail.css

# Debug, build as if on OpenWRT
#TARGET = -DOPENWRT
# Pwn Plug
#TARGET = -DPWNPLUG

# Compiler and options
CC = gcc
CFLAGS += -Wall -O2 $(TARGET)

# Libraries to link
LIBS = -lbluetooth

# Files
DOCS = ChangeLog COPYING README README.LIVE README.BAKTRK FUTURE

# Livelog.cgi prefix
CGIPRE = www/cgi-bin/

# Targets
# Build all
all: bluelog livelog

# Build Bluelog
bluelog:
	$(CC) $(CFLAGS) bluelog.c $(LIBS) -o $(APPNAME)

# Build CGI module
livelog:
	$(CC) $(CFLAGS) livelog.c -o $(CGIPRE)livelog.cgi

# Build tarball
release: clean
	tar --exclude='.git' -C ../ -czvf /tmp/$(APPNAME)-$(VERSION).tar.gz $(APPNAME)-$(VERSION)

# Clean for dist
clean:
	rm -rf $(APPNAME) $(CGIPRE)* *.o *.txt *.log *.gz *.cgi

# Install to system
install: bluelog livelog
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/usr/share/doc/$(APPNAME)-$(VERSION)/
	mkdir -p $(DESTDIR)/usr/share/man/man1
	mkdir -p $(DESTDIR)/var/lib/$(APPNAME)/
	cp $(APPNAME) $(DESTDIR)/usr/bin/
	cp -a $(DOCS) $(DESTDIR)/usr/share/doc/$(APPNAME)-$(VERSION)/
	gzip -c $(APPNAME).1 >> $(APPNAME).1.gz
	cp $(APPNAME).1.gz $(DESTDIR)/usr/share/man/man1/
	cp -a --no-preserve=ownership www/* $(DESTDIR)/var/lib/$(APPNAME)/
	cd $(DESTDIR)/var/lib/$(APPNAME)/ ; ln -sf $(DEFAULT_CSS) style.css

# Build for Pwn Plug
pwnplug:
	$(CC) $(CFLAGS) -DPWNPLUG bluelog.c $(LIBS) -o $(APPNAME)
	$(CC) $(CFLAGS) -DPWNPLUG livelog.c -o $(CGIPRE)livelog.cgi
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/var/www/$(APPNAME)/images
	cp $(APPNAME) $(DESTDIR)/usr/bin/
	cp --no-preserve=ownership www/*.html $(DESTDIR)/var/www/$(APPNAME)/
	cp --no-preserve=ownership -a www/cgi-bin $(DESTDIR)/var/www/
	cp --no-preserve=ownership www/pwnplug.css $(DESTDIR)/var/www/$(APPNAME)/style.css
	cp --no-preserve=ownership www/images/favicon.png $(DESTDIR)/var/www/$(APPNAME)/images/
	cp --no-preserve=ownership www/images/email.png $(DESTDIR)/var/www/$(APPNAME)/images/
	cp --no-preserve=ownership www/images/qrcontact.png $(DESTDIR)/var/www/$(APPNAME)/images/
	cp --no-preserve=ownership www/images/pwnplug_logo.png $(DESTDIR)/var/www/$(APPNAME)/images/

# Upgrade from previous source install
upgrade: removeold install

# Remove current version from system
uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/$(APPNAME)-$(VERSION)/
	rm -f $(DESTDIR)/usr/share/man/man1/$(APPNAME).1.gz
	rm -rf $(DESTDIR)/var/lib/$(APPNAME)/
	rm -f $(DESTDIR)/usr/bin/$(APPNAME)

# Remove older versions
removeold:
	rm -rf $(DESTDIR)/usr/share/doc/$(APPNAME)*
	rm -f $(DESTDIR)/usr/share/man/man1/$(APPNAME).1.gz
	rm -rf $(DESTDIR)/var/lib/$(APPNAME)*
	rm -f $(DESTDIR)/usr/bin/$(APPNAME)