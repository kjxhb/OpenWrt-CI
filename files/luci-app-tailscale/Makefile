# SPDX-License-Identifier: GPL-3.0-only
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-tailscale
PKG_VERSION:=1.2.3
PKG_RELEASE:=1

LUCI_TITLE:=LuCI for Tailscale
LUCI_DEPENDS:=+tailscale +luci-base
LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  LuCI application for managing Tailscale.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./luci/controller/tailscale.lua $(1)/usr/lib/lua/luci/controller/tailscale.lua
	$(INSTALL_DATA) ./luci/model/cbi/tailscale.lua $(1)/usr/lib/lua/luci/model/cbi/tailscale.lua
	$(INSTALL_DATA) ./luci/view/tailscale_status.htm $(1)/usr/lib/lua/luci/view/tailscale_status.htm
	$(INSTALL_DATA) ./luci/view/tailscale_log.htm $(1)/usr/lib/lua/luci/view/tailscale_log.htm

	# install runtime files from root/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) ./root/etc/init.d/tailscale $(1)/etc/init.d/tailscale
	$(INSTALL_BIN) ./root/usr/sbin/tailscale_helper $(1)/usr/sbin/tailscale_helper
	$(INSTALL_DATA) ./root/etc/hotplug.d/iface/40-tailscale $(1)/etc/hotplug.d/iface/40-tailscale
	$(INSTALL_DATA) ./root/etc/uci-defaults/40_luci-tailscale $(1)/etc/uci-defaults/40_luci-tailscale
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-tailscale.json $(1)/usr/share/rpcd/acl.d/luci-app-tailscale.json
	$(INSTALL_DATA) ./root/usr/share/luci/menu.d/luci-app-tailscale.json $(1)/usr/share/luci/menu.d/luci-app-tailscale.json
	$(INSTALL_DATA) ./root/etc/config/tailscale $(1)/etc/config/tailscale
endef
