#############################################################
#
# p0-renderer
#
#############################################################
P0_RENDERER_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
P0_RENDERER_DIR:=$(BUILD_DIR)/p0-renderer-$(P0_RENDERER_VERSION)
P0_RENDERER_TARGET_DIR:=raumfeld/p0-renderer
P0_RENDERER_BINARY:=$(P0_RENDERER_TARGET_DIR)/p0-renderer

P0_RENDERER_DEPENDENCIES = host-pkgconfig alsa-lib dbus-glib flac gstreamer liboil libraumfeld

ifeq ($(ARCH),arm)
P0_RENDERER_CROSS=ARM
else
ifeq ($(ARCH),i586)
P0_RENDERER_CROSS=GEODE
else
echo "renderer can only be build for ARM or GEODE"
exit 1
endif
endif

$(P0_RENDERER_DIR)/.bzr:
	if ! test -d $(P0_RENDERER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p p0-renderer-$(P0_RENDERER_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/p0-renderer p0-renderer-$(P0_RENDERER_VERSION)) \
	fi
	touch -c $@

p0-renderer-source: $(P0_RENDERER_DIR)/.bzr 

$(STAGING_DIR)/$(P0_RENDERER_BINARY): p0-renderer-source
	$(MAKE) -C $(P0_RENDERER_DIR) CROSS=$(P0_RENDERER_CROSS) DEST=$(STAGING_DIR)/raumfeld

$(TARGET_DIR)/$(P0_RENDERER_BINARY): $(STAGING_DIR)/$(P0_RENDERER_BINARY)
	$(MAKE) -C $(P0_RENDERER_DIR) CROSS=$(P0_RENDERER_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(P0_RENDERER_BINARY)

p0-renderer: uclibc host-pkgconfig raumfeld gstreamer flac liboil $(TARGET_DIR)/$(P0_RENDERER_BINARY)

p0-renderer-clean:
	rm -f $(STAGING_DIR)/$(P0_RENDERER_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(P0_RENDERER_DIR) clean CROSS=$(P0_RENDERER_CROSS)

p0-renderer-dirclean:
	rm -rf $(P0_RENDERER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_RENDERER),y)
TARGETS+=p0-renderer
endif
