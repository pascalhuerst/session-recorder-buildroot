#############################################################
#
# libraumfeld
#
#############################################################

LIBRAUMFELD_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
LIBRAUMFELD_AUTORECONF = YES
LIBRAUMFELD_LIBTOOL_PATCH = NO
LIBRAUMFELD_INSTALL_STAGING = YES
LIBRAUMFELD_INSTALL_TARGET = YES

LIBRAUMFELD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums

LIBRAUMFELD_CONF_OPT = \
	--localstatedir=/var	\
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

ifeq ($(BR2_PACKAGE_LIBRAUMFELD_PROFILING),y)
LIBRAUMFELD_CONF_OPT += --enable-profiling
endif

LIBRAUMFELD_DEPENDENCIES = \
	host-pkgconfig host-libglib2 \
	avahi dbus-glib gupnp-av openssl libarchive libunwind

$(eval $(call AUTOTARGETS,package/raumfeld,libraumfeld))

$(LIBRAUMFELD_DIR)/.bzr:
	if ! test -d $(LIBRAUMFELD_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeld/$(LIBRAUMFELD_VERSION) libraumfeld-$(LIBRAUMFELD_VERSION)) \
	fi

$(LIBRAUMFELD_DIR)/.stamp_downloaded: $(LIBRAUMFELD_DIR)/.bzr
	touch $@

$(LIBRAUMFELD_DIR)/.stamp_extracted: $(LIBRAUMFELD_DIR)/.stamp_downloaded
	(cd $(LIBRAUMFELD_DIR); gtkdocize)
	touch $@

ifeq ($(BR2_arm),y)
$(LIBRAUMFELD_HOOK_POST_CONFIGURE):
	$(call MESSAGE,"Patching libtool for static linking")
	cat package/raumfeld/libraumfeld/libtool-static-arm.patch | patch -p1 -d $(LIBRAUMFELD_DIR)
	touch $@
endif
