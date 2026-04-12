include $(TOPDIR)/rules.mk

# 1. 基础信息
PKG_NAME:=luci-app-GEPH5
PKG_VERSION:=0.2.94
PKG_RELEASE:=1

# 2. 告诉 OpenWrt 正规的下载源：直接从 crates.io 拉取压缩包
PKG_SOURCE:=geph5-client-$(PKG_VERSION).crate
PKG_SOURCE_URL:=https://static.crates.io/crates/geph5-client
PKG_HASH:=skip

# 3. 极其重要：纠正解压后的源码目录名
# 虽然我们的包名叫 GEPH5，但官方 crate 解压出来的文件夹叫 geph5-client-0.2.94
PKG_BUILD_DIR:=$(BUILD_DIR)/geph5-client-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-GEPH5
	SECTION:=net
	CATEGORY:=Network
	TITLE:=GEPH5 Client with LuCI Web UI
	DEPENDS:=+ca-certificates +luci-base
endef

# ==========================================
# 准备阶段：OpenWrt 会自动下载 .crate，我们负责把它解压
# ==========================================
define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	# .crate 本质就是 tar.gz，直接解压到 BUILD_DIR
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(BUILD_DIR)
endef

# ==========================================
# 编译阶段：进入解压好的源码目录，进行交叉编译
# ==========================================
define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	cargo build --release --target=x86_64-unknown-linux-musl
endef

# ==========================================
# 安装阶段
# ==========================================
define Package/luci-app-GEPH5/install
	# 安装编译出的二进制文件
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/x86_64-unknown-linux-musl/release/geph5-client $(1)/usr/bin/

	# 安装配置和 LuCI 界面文件
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/geph5 $(1)/etc/config/geph5
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/geph5 $(1)/etc/init.d/geph5

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/geph5.lua $(1)/usr/lib/lua/luci/controller/geph5.lua
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/geph5.lua $(1)/usr/lib/lua/luci/model/cbi/geph5.lua
endef

define Package/GEPH5/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/geph5 enable
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-GEPH5))
