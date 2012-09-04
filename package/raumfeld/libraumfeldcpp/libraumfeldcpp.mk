#############################################################
#
# libraumfeldcpp
#
#############################################################

LIBRAUMFELDCPP_MODULE = raumfeldcpp
LIBRAUMFELDCPP_INSTALL_STAGING = YES

LIBRAUMFELDCPP_CONF_OPT = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest

LIBRAUMFELDCPP_DEPENDENCIES = host-pkg-config libsoup libraumfeld

$(eval $(raumfeld-autotools-package))
