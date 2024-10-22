# This file is part of Named Constant Generator.
# Copyright © 2009,2010,2011,2012 Johannes Willkomm 
# See the file gennc for copying conditions.

PROJ_NAME = mpd-smartplaylists

INSTALL ?= install
DESTDIR ?= 

prefix        ?= /usr/local
instprefix     = $(DESTDIR)$(prefix)
exec_prefix   ?= $(instprefix)
bindir        ?= $(exec_prefix)/bin
datarootdir   ?= $(instprefix)/share
includedir    ?= $(instprefix)/include
libdir        ?= $(exec_prefix)/lib
docdir        ?= $(datarootdir)/doc/$(PROJ_NAME)
mandir        ?= $(datarootdir)/man
man1dir       ?= $(mandir)/man1
man3dir       ?= $(mandir)/man3
datadir       ?= $(datarootdir)/$(PROJ_NAME)
projlibdir    ?= $(libdir)/$(PROJ_NAME)
shdir         ?= $(projlibdir)/scripts
xsldir        ?= $(projlibdir)/xsl
srcdir        ?= .

XSLS = $(addprefix $(srcdir)/, copy.xsl \
	create-smartplaylist.xsl \
	create-smartplaylist2.xsl \
	genupdate-sh.xsl \
	smartplaylist-distrib-or.xsl \
	smartplaylist-has-paren.xsl \
)
SHS = $(addprefix $(srcdir)/,\
copy-mpd-to-handy.sh\
copy-mpd-to-host.sh\
copy-rsync-from-mpd.sh\
copy-rsync-mpd-to-host.sh\
copy-tarred-mpd-to-host.sh\
mpd-command.sh\
mpd-shell-in-dir.sh\
smartplaylist-create.sh\
smartplaylist-distrib-or-over-and.sh\
smartplaylist-query.sh\
smartplaylist-txt2xml.sh\
sniff-input-type.sh\
update-mpd-smartplaylists.sh\
)

examples =

default all: mpd-smartplaylists.1 $(examples)

mpd-smartplaylists: smartplaylist.sh
	cp -a $< $@

mpd-smartplaylists.1: mpd-smartplaylists man-texts.txt
	LANG=C PATH=.:$$PATH help2man -Len_US.utf8 -N --include man-texts.txt ./mpd-smartplaylists > $@

install: mpd-smartplaylists mpd-smartplaylists.1 $(examples)
	$(INSTALL) -d $(bindir) $(xsldir) $(shdir) $(man1dir) $(docdir)
	$(INSTALL) $(srcdir)/mpd-smartplaylists $(bindir)
	$(INSTALL) p2x.conf Makefile.mpdsp $(projlibdir)
	$(INSTALL) -m 644 $(XSLS) $(xsldir)
	$(INSTALL) -m 755 $(SHS) $(shdir)
	$(INSTALL) -m 644  $(srcdir)/mpd-smartplaylists.1 $(man1dir)
	$(INSTALL) -m 644 README.txt $(docdir)

clean:
	$(RM) mpd-smartplaylists.1 $(examples)

test check: test1 test2

test1:
	./tests/test_parser.sh

test2:
	./tests/test_parser2.sh

.PHONY: test check
