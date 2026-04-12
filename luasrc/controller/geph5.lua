module("luci.controller.geph5", package.seeall)

function index()
	-- 如果配置文件不存在，则不显示菜单
	if not nixio.fs.access("/etc/config/geph5") then return end

	-- 注册菜单：admin(管理权限) -> services(服务菜单) -> geph5
	entry({"admin", "services", "geph5"}, cbi("geph5"), _("GEPH5"), 60)
end
