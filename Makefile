##################################################################
# @(#) $Id: Makefile,v 2.4 2003/09/13 18:04:29 pwo Exp $
# @(#) mrtg-ping-probe release $Name: Release_2_2_0 $
#
# Copyright (c) 1997-2003 Peter W. Osel <pwo@pwo.de>.
# All Rights Reserved.
#
# See the file COPYRIGHT in the distribution for the exact terms.
#
##################################################################
# Makefile for mrtg-ping-probe
##################################################################

PKG_NAME	= mrtg-ping-probe
PKG_NAME_DOS	= pingp
PKG_MAIN	= pwo@pwo.de
TAR		= gtar
SHAR		= gshar
ZIP		= zip
MD5SUM		= gmd5sum
PGP		= pgp

srcdir		= .

POD		= mrtg-ping-probe
MAN		= $(POD).1
HTML		= $(POD).html
TEX		= $(POD).tex

DIST_COMMON	= COPYING COPYRIGHT ChangeLog INSTALL Makefile NEWS README TODO
SOURCES		= mrtg-ping-probe
EXTRA_DIST	= check-ping-fmt mrtg-ping-cfg mrtg.cfg-ping

DISTFILES	= $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(MANS) $(EXTRA_DIST)

all:	man

man: $(MAN)
$(MAN):	$(POD)
	pod2man $(POD) > $(MAN)

html: $(HTML)
$(HTML): $(POD)
	pod2html $(POD) > $(HTML)

tex: $(TEX)
$(TEX):	$(POD)
	pod2latex $(POD) > $(TEX)

clean:
	rm -f $(MAN) $(HTML) $(TEX)

realclean:	clean

distclean:	realclean


########################################################################
# dist: create the distribution tar and shar files
#		we rely that dist-ok does all error checking
dist: dist-ok dist-dir
	@rel_tag=`grep "$(PKG_NAME) release" Makefile | sed -e 's/.*: //' -e 's/ .*$$//'`; \
	rel_ver=`echo $$rel_tag | sed -e 's/^Release_//' -e 's/_/./g'`; \
	rel_ver_dos=`echo $$rel_ver | sed -e 's/\.//g'`; \
	distdir=$(PKG_NAME)-$$rel_ver; \
	distdirdos=$(PKG_NAME_DOS)-$$rel_ver_dos; \
	GZIP=-9; export GZIP; \
	$(TAR) chozf $$distdir.tar.gz $$distdir; \
	$(SHAR) -n $(PKG_NAME) -a -z -c -s $(PKG_MAIN) -o $$distdir.shar $$distdir; \
	mv $$distdir $$distdirdos; \
	$(ZIP) -or $$distdirdos $$distdirdos; \
	rm -rf $$distdirdos; \
	for file in $$distdir.tar.gz $$distdirdos.zip $$distdir.shar.[0-9][0-9]; do \
		rm -f $$file.md5 $$file.md5.asc; \
		$(MD5SUM) $$file > $$file.md5; \
		$(PGP) -sta $$file.md5 && mv $$file.md5.asc $$file.md5; \
		chmod 444 $$file.md5; \
		done;

########################################################################
# dist-ok: ok to create a distribution?
#	check for valid Release tag in Makefile
#	check for current NEWS file
dist-ok:
	@rel_tag=`grep "$(PKG_NAME) release" Makefile | sed -e 's/.*: //' -e 's/ .*$$//'`; \
	rel_ver=`echo $$rel_tag | sed -e 's/^Release_//' -e 's/_/./g'`; \
	if test -z "$$rel_tag" ; then \
		echo "Makefile(dist-ok): empty release tag $$rel_tag; not releasing" 1>&2; \
		exit 1; \
		fi; \
	if grep $$rel_tag NEWS > /dev/null; then \
		echo "Makefile(dist-ok): found release tag $$rel_tag for $(PKG_NAME) release $$rel_ver"; \
	else \
		echo "Makefile(dist-ok): Can't find Release Tag $$rel_tag in file NEWS" 1>&2; \
		echo "Makefile(dist-ok): not releasing" 1>&2; \
		exit 1; \
		fi ; \

########################################################################
# dist-dir: create the distribution directory
#		we rely that dist-ok has already been called
dist-dir: $(DISTFILES)
	@rel_tag=`grep "$(PKG_NAME) release" Makefile | sed -e 's/.*: //' -e 's/ .*$$//'`; \
	rel_ver=`echo $$rel_tag | sed -e 's/^Release_//' -e 's/_/./g'`; \
	rel_ver_dos=`echo $$rel_ver | sed -e 's/\.//g'`; \
	distdir=$(PKG_NAME)-$$rel_ver; \
	distdirdos=$(PKG_NAME_DOS)-$$rel_ver_dos; \
	rm -rf $$distdir $$distdirdos; \
	mkdir $$distdir; \
	for file in $(DISTFILES); do \
		d=$(srcdir); \
		test -f $$distdir/$$file \
		|| ln $$d/$$file $$distdir/$$file 2> /dev/null \
		|| cp -p $$d/$$file $$distdir/$$file; \
		done; \
	chmod -R a+rX $$distdir;
