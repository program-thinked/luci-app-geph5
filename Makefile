include $(TOPDIR)/rules.mk

# 1. 基础信息
PKG_NAME:=luci-app-GEPH5
PKG_VERSION:=0.2.99
PKG_RELEASE:=1

# 2. 编译目标定义 (核心锚点：会被 build.yml 中的 sed 替换成 aarch64 等)
RUST_TARGET:=x86_64-unknown-linux-musl

# 3. 告诉 OpenWrt 正规的下载源
PKG_SOURCE:=geph5-client-$(PKG_VERSION).crate
PKG_SOURCE_URL:=https://static.crates.io/crates/geph5-client
PKG_HASH:=skip

# 4. 纠正解压后的源码目录名
PKG_BUILD_DIR:=$(BUILD_DIR)/geph5-client-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-GEPH5
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GEPH5 Client with LuCI Web UI
  DEPENDS:=+ca-certificates +luci-base
endef

# ==========================================
# 准备阶段：解压官方 .crate 压缩包
# ==========================================
define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	# .crate 本质就是 tar.gz，直接解压到 BUILD_DIR
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(BUILD_DIR)
endef

# ==========================================
# 编译阶段：修复 ARM 链接器错误
# ==========================================
define Build/Compile
	( \
		export CARGO_HOME=$(HOME)/.cargo; \
		export CC_$(subst -,_,$(RUST_TARGET))="$(TARGET_CC)"; \
		export AR_$(subst -,_,$(RUST_TARGET))="$(TARGET_AR)"; \
		$(CARGO_PKG_VARS) \
		RUSTFLAGS="-C linker=$(TARGET_CC)" \
		cargo build \
			--target $(RUST_TARGET) \
			--release \
			--manifest-path $(PKG_BUILD_DIR)/Cargo.toml; \
	)
endef

# ==========================================
# 安装阶段：注意路径必须使用变量
# ==========================================
define Package/luci-app-GEPH5/install
	# 安装编译出的二进制文件
	# 注意：这里的路径必须使用 $(RUST_TARGET)，否则 aarch64 编译时会找不到文件
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUST_TARGET)/release/geph5-client $(1)/usr/bin/

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

# ==========================================
# 后处理阶段：安装后自动启用服务
# ==========================================
# 注意：这里的名字必须是 Package/luci-app-GEPH5/postinst
define Package/luci-app-GEPH5/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/geph5 enable
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-GEPH5))
