m = Map("geph5", translate("GEPH5"), translate("支持多实例运行。后台会自动分配 Control/PAC 端口并生成独立的 YAML 配置文件。"))

s = m:section(TypedSection, "profile", translate("代理节点实例"))
s.addremove = true
s.anonymous = false

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

o = s:option(Value, "secret", translate("Secret 凭证"))
o.password = true
o.rmempty = false

o = s:option(ListValue, "cdn77_mode", translate("CDN77 域前置获取"))
o:value("auto", translate("自动分配 (Auto / null)"))
o:value("manual", translate("手动指定未墙 IP"))
o.default = "auto"

o = s:option(Value, "cdn77_ip", translate("CDN77 IP 地址"), translate("只需填写 IP (如 95.173.204.18)，系统会自动拼接 :443"))
o.datatype = "ip4addr"
o:depends("cdn77_mode", "manual")

o = s:option(ListValue, "exit_mode", translate("出口选择模式"))
o:value("auto", translate("自动选择 (Auto)"))
o:value("country_city", translate("指定国家/城市 (Country/City)"))
o.default = "country_city"

o = s:option(Value, "exit_country", translate("国家代码"), translate("例如填写 JP, US 等。"))
o:depends("exit_mode", "country_city")
o.default = "JP"

o = s:option(Value, "exit_city", translate("城市名称"), translate("例如填写 Tokyo 等,可使用手机端的GEPH查看具体节点。区分大小写。"))
o:depends("exit_mode", "country_city")
o.default = "Tokyo"

o = s:option(Value, "http_proxy_ip", translate("HTTP 代理监听 IP"))
o.datatype = "ipaddr"
o.default = "127.0.0.1"

o = s:option(Value, "http_proxy_port", translate("HTTP 代理端口"), translate("多实例请确保此端口互不冲突。"))
o.datatype = "port"
o.default = "9910"

o = s:option(Value, "socks5_ip", translate("Socks5 监听 IP"))
o.datatype = "ipaddr"
o.default = "127.0.0.1"

o = s:option(Value, "socks5_port", translate("Socks5 端口"), translate("多实例请确保此端口互不冲突。"))
o.datatype = "port"
o.default = "9909"

return m
