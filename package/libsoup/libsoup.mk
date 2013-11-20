################################################################################
#
# libsoup
#
################################################################################

LIBSOUP_MAJOR_VERSION = 2.42
LIBSOUP_MINOR_VERSION = 2
LIBSOUP_VERSION = $(LIBSOUP_MAJOR_VERSION).$(LIBSOUP_MINOR_VERSION)
LIBSOUP_SOURCE = libsoup-$(LIBSOUP_VERSION).tar.xz
LIBSOUP_SITE = http://ftp.gnome.org/pub/gnome/sources/libsoup/$(LIBSOUP_MAJOR_VERSION)
LIBSOUP_LICENSE = LGPLv2+
LIBSOUP_LICENSE_FILES = COPYING
LIBSOUP_INSTALL_STAGING = YES

LIBSOUP_CONF_ENV = ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

ifneq ($(BR2_INET_IPV6),y)
LIBSOUP_CONF_ENV += soup_cv_ipv6=no
endif

LIBSOUP_CONF_OPT = --disable-glibtest --without-gnome

LIBSOUP_DEPENDENCIES = host-pkgconf host-libglib2 \
       libglib2 libxml2 sqlite host-intltool

ifeq ($(BR2_PACKAGE_LIBSOUP_SSL),y)
LIBSOUP_DEPENDENCIES += glib-networking
else
LIBSOUP_CONF_OPT += --disable-tls-check
endif

$(eval $(autotools-package))
