################################################################################
#
# gupnp
#
################################################################################

GUPNP_VERSION_MAJOR = 1.0
GUPNP_VERSION = $(GUPNP_VERSION_MAJOR).1
GUPNP_SOURCE = gupnp-$(GUPNP_VERSION).tar.xz
GUPNP_SITE = http://ftp.gnome.org/pub/gnome/sources/gupnp/$(GUPNP_VERSION_MAJOR)
GUPNP_LICENSE = LGPLv2+
GUPNP_LICENSE_FILES = COPYING
GUPNP_INSTALL_STAGING = YES
GUPNP_DEPENDENCIES = host-pkgconf libglib2 libxml2 gssdp util-linux

ifeq ($(BR2_PACKAGE_NETWORK_MANAGER),y)
	GUPNP_CONF_OPTS = --with-context-manager=network-manager
	GUPNP_DEPENDENCIES += networkmanager
else ifeq ($(BR2_PACKAGE_CONNMAN),y)
	GUPNP_CONF_OPTS = --with-context-manager=connman
	GUPNP_DEPENDENCIES += connman
endif

$(eval $(autotools-package))
