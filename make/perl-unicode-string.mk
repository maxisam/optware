###########################################################
#
# perl-unicode-string
#
###########################################################

PERL-UNICODE-STRING_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-UNICODE-STRING_VERSION=2.09
PERL-UNICODE-STRING_SOURCE=Unicode-String-$(PERL-UNICODE-STRING_VERSION).tar.gz
PERL-UNICODE-STRING_DIR=Unicode-String-$(PERL-UNICODE-STRING_VERSION)
PERL-UNICODE-STRING_UNZIP=zcat
PERL-UNICODE-STRING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-UNICODE-STRING_DESCRIPTION=Unicode-String - String of Unicode characters (UTF-16BE)
PERL-UNICODE-STRING_SECTION=util
PERL-UNICODE-STRING_PRIORITY=optional
PERL-UNICODE-STRING_DEPENDS=perl, perl-compress-zlib
PERL-UNICODE-STRING_SUGGESTS=
PERL-UNICODE-STRING_CONFLICTS=

PERL-UNICODE-STRING_IPK_VERSION=1

PERL-UNICODE-STRING_CONFFILES=

PERL-UNICODE-STRING_BUILD_DIR=$(BUILD_DIR)/perl-unicode-string
PERL-UNICODE-STRING_SOURCE_DIR=$(SOURCE_DIR)/perl-unicode-string
PERL-UNICODE-STRING_IPK_DIR=$(BUILD_DIR)/perl-unicode-string-$(PERL-UNICODE-STRING_VERSION)-ipk
PERL-UNICODE-STRING_IPK=$(BUILD_DIR)/perl-unicode-string_$(PERL-UNICODE-STRING_VERSION)-$(PERL-UNICODE-STRING_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-UNICODE-STRING_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-UNICODE-STRING_SITE)/$(PERL-UNICODE-STRING_SOURCE)

perl-unicode-string-source: $(DL_DIR)/$(PERL-UNICODE-STRING_SOURCE) $(PERL-UNICODE-STRING_PATCHES)

$(PERL-UNICODE-STRING_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-UNICODE-STRING_SOURCE) $(PERL-UNICODE-STRING_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-UNICODE-STRING_DIR) $(PERL-UNICODE-STRING_BUILD_DIR)
	$(PERL-UNICODE-STRING_UNZIP) $(DL_DIR)/$(PERL-UNICODE-STRING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-UNICODE-STRING_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-UNICODE-STRING_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-UNICODE-STRING_DIR) $(PERL-UNICODE-STRING_BUILD_DIR)
	(cd $(PERL-UNICODE-STRING_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-UNICODE-STRING_BUILD_DIR)/.configured

perl-unicode-string-unpack: $(PERL-UNICODE-STRING_BUILD_DIR)/.configured

$(PERL-UNICODE-STRING_BUILD_DIR)/.built: $(PERL-UNICODE-STRING_BUILD_DIR)/.configured
	rm -f $(PERL-UNICODE-STRING_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-UNICODE-STRING_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-UNICODE-STRING_BUILD_DIR)/.built

perl-unicode-string: $(PERL-UNICODE-STRING_BUILD_DIR)/.built

$(PERL-UNICODE-STRING_BUILD_DIR)/.staged: $(PERL-UNICODE-STRING_BUILD_DIR)/.built
	rm -f $(PERL-UNICODE-STRING_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-UNICODE-STRING_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-UNICODE-STRING_BUILD_DIR)/.staged

perl-unicode-string-stage: $(PERL-UNICODE-STRING_BUILD_DIR)/.staged

$(PERL-UNICODE-STRING_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-UNICODE-STRING_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-unicode-string" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-UNICODE-STRING_PRIORITY)" >>$@
	@echo "Section: $(PERL-UNICODE-STRING_SECTION)" >>$@
	@echo "Version: $(PERL-UNICODE-STRING_VERSION)-$(PERL-UNICODE-STRING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-UNICODE-STRING_MAINTAINER)" >>$@
	@echo "Source: $(PERL-UNICODE-STRING_SITE)/$(PERL-UNICODE-STRING_SOURCE)" >>$@
	@echo "Description: $(PERL-UNICODE-STRING_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-UNICODE-STRING_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-UNICODE-STRING_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-UNICODE-STRING_CONFLICTS)" >>$@

$(PERL-UNICODE-STRING_IPK): $(PERL-UNICODE-STRING_BUILD_DIR)/.built
	rm -rf $(PERL-UNICODE-STRING_IPK_DIR) $(BUILD_DIR)/perl-unicode-string_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-UNICODE-STRING_BUILD_DIR) DESTDIR=$(PERL-UNICODE-STRING_IPK_DIR) install
	find $(PERL-UNICODE-STRING_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-UNICODE-STRING_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-UNICODE-STRING_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-UNICODE-STRING_IPK_DIR)/CONTROL/control
	echo $(PERL-UNICODE-STRING_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-UNICODE-STRING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-UNICODE-STRING_IPK_DIR)

perl-unicode-string-ipk: $(PERL-UNICODE-STRING_IPK)

perl-unicode-string-clean:
	-$(MAKE) -C $(PERL-UNICODE-STRING_BUILD_DIR) clean

perl-unicode-string-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-UNICODE-STRING_DIR) $(PERL-UNICODE-STRING_BUILD_DIR) $(PERL-UNICODE-STRING_IPK_DIR) $(PERL-UNICODE-STRING_IPK)
