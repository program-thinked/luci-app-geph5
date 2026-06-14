include $(TOPDIR)/rules.mk

# 【改造点1：全面小写，符合 APK 标准】
PKG_NAME:=luci-app-geph5
PKG_VERSION:=0.2.102
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Program-thinked <admin@example.com>

RUST_TARGET:=x86_64-unknown-linux-musl

PKG_SOURCE:=geph5-client-$(PKG_VERSION).crate
PKG_SOURCE_URL:=https://static.crates.io/crates/geph5-client
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/geph5-client-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-geph5
  SECTION:=net
  CATEGORY:=Network
  TITLE:=geph5 Client with LuCI Web UI
  # 【改造点2：显式声明该包与硬件架构强绑定】
  DEPENDS:=+ca-certificates +luci-base +luci-compat
endef

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(BUILD_DIR)
endef

define Build/Compile
	( \
		export CARGO_HOME=$(HOME)/.cargo; \
		export CC_$(subst -,_,$(RUST_TARGET))="$(TARGET_CC)"; \
		export AR_$(subst -,_,$(RUST_TARGET))="$(TARGET_AR)"; \
		$(CARGO_PKG_VARS) \
		RUSTFLAGS="-C linker=$(firstword $(TARGET_CC))" \
		cargo build \
			--target $(RUST_TARGET) \
			--release \
			--manifest-path $(PKG_BUILD_DIR)/Cargo.toml; \
	)
endef

define Package/luci-app-geph5/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUST_TARGET)/release/geph5-client $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/geph5 $(1)/etc/config/geph5
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/geph5 $(1)/etc/init.d/geph5

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/geph5.lua $(1)/usr/lib/lua/luci/controller/geph5.lua
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/geph5.lua $(1)/usr/lib/lua/luci/model/cbi/geph5.lua
endef

define Package/luci-app-geph5/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ] && [ -z "$${PKG_ROOT}" ]; then
	/etc/init.d/geph5 enable
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-geph5))