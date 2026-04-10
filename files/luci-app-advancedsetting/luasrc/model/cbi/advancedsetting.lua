-- Copyright (C) 2018 dz <dingzhong110@gmail.com>

local fs = require "nixio.fs"
local sys = require "luci.sys"

m = Map("advancedsetting", translate("高级进阶设置"))
m.description = translate("<br /><font color=\"Red\"><strong>配置文档是直接编辑的！除非你知道自己在干什么，否则请不要轻易修改这些配置文档。配置不正确可能会导致不能开机等错误。</strong></font><br/>")

s = m:section(TypedSection, "advancedsetting")
s.anonymous = true

--dnsmasq
if nixio.fs.access("/etc/dnsmasq.conf") then
s:tab("config1", translate("配置dnsmasq"), translate("本页是配置/etc/dnsmasq.conf的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config1", Value, "editconf1", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/dnsmasq.conf") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/dnsmasq.conf", value)
		if (luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf") == 1) then
			fs.writefile("/etc/dnsmasq.conf", value)
			luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
		end
		fs.remove("/tmp/dnsmasq.conf")
	end
end
end

--network
if nixio.fs.access("/etc/config/network") then
s:tab("config2", translate("配置网络"), translate("本页是配置/etc/config/network的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config2", Value, "editconf2", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/network") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/netwok", value)
		if (luci.sys.call("cmp -s /tmp/network /etc/config/network") == 1) then
			fs.writefile("/etc/config/network", value)
			luci.sys.call("/etc/init.d/network restart >/dev/null")
		end
		fs.remove("/tmp/network")
	end
end
end

--wireless
if nixio.fs.access("/etc/config/wireless") then
s:tab("config3", translate("配置WIFI"), translate("本页是配置/etc/config/wireless的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config3", Value, "editconf3", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/wireless") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/wireless", value)
		if (luci.sys.call("cmp -s /tmp/wireless /etc/config/wireless") == 1) then
			fs.writefile("/etc/config/wireless", value)
			luci.sys.call("wifi reload >/dev/null &")
		end
		fs.remove("/tmp/wireless")
	end
end
end

--firewall
if nixio.fs.access("/etc/config/firewall") then
s:tab("config4", translate("配置防火墙"), translate("本页是配置/etc/config/firewall的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config4", Value, "editconf4", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/firewall") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/firewall", value)
		if (luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall") == 1) then
			fs.writefile("/etc/config/firewall", value)
			luci.sys.call("/etc/init.d/firewall restart >/dev/null")
		end
		fs.remove("/tmp/firewall")
	end
end
end

--hosts
if nixio.fs.access("/etc/hosts") then
s:tab("config5", translate("配置hosts"), translate("本页是配置/etc/hosts的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config5", Value, "editconf5", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/hosts") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/etc/hosts", value)
		if (luci.sys.call("cmp -s /tmp/etc/hosts /etc/hosts") == 1) then
			fs.writefile("/etc/hosts", value)
			luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
		end
		fs.remove("/tmp/etc/hosts")
	end
end
end

--dhcp
if nixio.fs.access("/etc/config/dhcp") then
s:tab("config6", translate("配置DHCP"), translate("本页是配置/etc/config/dhcp的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config6", Value, "editconf6", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/dhcp") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/dhcp", value)
		if (luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp") == 1) then
			fs.writefile("/etc/config/dhcp", value)
			luci.sys.call("/etc/init.d/dhcp restart >/dev/null")
		end
		fs.remove("/tmp/dhcp")
	end
end
end

--arpbind
if nixio.fs.access("/etc/config/arpbind") then
s:tab("config7", translate("MAC/IP绑定"), translate("本页是配置/etc/config/arpbind的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config7", Value, "editconf7", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/arpbind") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/arpbind", value)
		if (luci.sys.call("cmp -s /tmp/arpbind /etc/config/arpbind") == 1) then
			fs.writefile("/etc/config/arpbind", value)
			luci.sys.call("/etc/init.d/arpbind restart >/dev/null")
		end
		fs.remove("/tmp/arpbind")
	end
end
end

--mwan3
if nixio.fs.access("/etc/config/mwan3") then
s:tab("config8", translate("配置负载均衡"), translate("本页是配置/etc/config/mwan3的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config8", Value, "editconf8", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/mwan3") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/mwan3", value)
		if (luci.sys.call("cmp -s /tmp/mwan3 /etc/config/mwan3") == 1) then
			fs.writefile("/etc/config/mwan3", value)
			luci.sys.call("/etc/init.d/mwan3 restart >/dev/null")
		end
		fs.remove("/tmp/mwan3")
	end
end
end

--ddns
if nixio.fs.access("/etc/config/ddns") then
s:tab("config9", translate("配置动态DNS"), translate("本页是配置/etc/config/ddns的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config9", Value, "editconf9", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/ddns") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/ddns", value)
		if (luci.sys.call("cmp -s /tmp/ddns /etc/config/ddns") == 1) then
			fs.writefile("/etc/config/ddns", value)
			luci.sys.call("/etc/init.d/ddns restart >/dev/null")
		end
		fs.remove("/tmp/ddns")
	end
end
end

--smartdns
if nixio.fs.access("/etc/config/smartdns") then
s:tab("config10", translate("配置smartdns"), translate("本页是配置/etc/config/smartdns的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config10", Value, "editconf10", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/smartdns") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/smartdns", value)
		if (luci.sys.call("cmp -s /tmp/smartdns /etc/config/smartdns") == 1) then
			fs.writefile("/etc/config/smartdns", value)
			luci.sys.call("/etc/init.d/smartdns restart >/dev/null")
		end
		fs.remove("/tmp/smartdns")
	end
end
end

--openclash
if nixio.fs.access("/etc/config/openclash") then
s:tab("config11", translate("配置openclash"), translate("本页是配置/etc/config/openclash的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config11", Value, "editconf11", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/openclash") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/openclash", value)
		if (luci.sys.call("cmp -s /tmp/openclash /etc/config/openclash") == 1) then
			fs.writefile("/etc/config/openclash", value)
			luci.sys.call("/etc/init.d/openclash restart >/dev/null")
		end
		fs.remove("/tmp/openclash")
	end
end
end

--uhttpd
if nixio.fs.access("/etc/config/uhttpd") then
s:tab("config12", translate("配置WEB管理"), translate("本页是配置/etc/config/uhttpd的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config12", Value, "editconf12", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/uhttpd") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/uhttpd", value)
		if (luci.sys.call("cmp -s /tmp/uhttpd /etc/config/uhttpd") == 1) then
			fs.writefile("/etc/config/uhttpd", value)
			luci.sys.call("/etc/init.d/uhttpd restart >/dev/null")
		end
		fs.remove("/tmp/uhttpd")
	end
end
end

--hd-idle
if nixio.fs.access("/etc/config/hd-idle") then
s:tab("config13", translate("配置硬盘休眠"), translate("本页是配置/etc/config/hd-idle的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config13", Value, "editconf13", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/hd-idle") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/hd-idle", value)
		if (luci.sys.call("cmp -s /tmp/hd-idle /etc/config/hd-idle") == 1) then
			fs.writefile("/etc/config/hd-idle", value)
			luci.sys.call("/etc/init.d/hd-idle restart >/dev/null")
		end
		fs.remove("/tmp/hd-idle")
	end
end
end

--samba4
if nixio.fs.access("/etc/config/samba4") then
s:tab("config14", translate("配置网络共享"), translate("本页是配置/etc/config/samba4的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config14", Value, "editconf14", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/samba4") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/samba4", value)
		if (luci.sys.call("cmp -s /tmp/samba4 /etc/config/samba4") == 1) then
			fs.writefile("/etc/config/samba4", value)
			luci.sys.call("/etc/init.d/samba4 restart >/dev/null")
		end
		fs.remove("/tmp/samba4")
	end
end
end

--vsftpd
if nixio.fs.access("/etc/config/vsftpd") then
s:tab("config15", translate("配置FTP"), translate("本页是配置/etc/config/vsftpd的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config15", Value, "editconf15", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/vsftpd") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/vsftpd", value)
		if (luci.sys.call("cmp -s /tmp/vsftpd /etc/config/vsftpd") == 1) then
			fs.writefile("/etc/config/vsftpd", value)
			luci.sys.call("/etc/init.d/vsftpd restart >/dev/null")
		end
		fs.remove("/tmp/vsftpd")
	end
end
end

--samba
if nixio.fs.access("/etc/config/samba") then
s:tab("config16", translate("配置网络共享"), translate("本页是配置/etc/config/samba的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config16", Value, "editconf16", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/samba") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/samba", value)
		if (luci.sys.call("cmp -s /tmp/samba /etc/config/samba") == 1) then
			fs.writefile("/etc/config/samba", value)
			luci.sys.call("/etc/init.d/samba restart >/dev/null")
		end
		fs.remove("/tmp/samba")
	end
end
end

--cloudflared
if nixio.fs.access("/etc/config/cloudflared") then
s:tab("config17", translate("配置cloudflared"), translate("本页是配置/etc/config/cloudflared的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config17", Value, "editconf17", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/cloudflared") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/cloudflared", value)
		if (luci.sys.call("cmp -s /tmp/cloudflared /etc/config/cloudflared") == 1) then
			fs.writefile("/etc/config/cloudflared", value)
			luci.sys.call("/etc/init.d/cloudflared restart >/dev/null")
		end
		fs.remove("/tmp/cloudflared")
	end
end
end

--zerotier
if nixio.fs.access("/etc/config/zerotier") then
s:tab("config18", translate("配置zerotier"), translate("本页是配置/etc/config/zerotier的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config18", Value, "editconf18", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/zerotier") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/zerotier", value)
		if (luci.sys.call("cmp -s /tmp/zerotier /etc/config/zerotier") == 1) then
			fs.writefile("/etc/config/zerotier", value)
			luci.sys.call("/etc/init.d/zerotier restart >/dev/null")
		end
		fs.remove("/tmp/zerotier")
	end
end
end

--tailscale
if nixio.fs.access("/etc/config/tailscale") then
s:tab("config19", translate("配置tailscale"), translate("本页是配置/etc/config/tailscale的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config19", Value, "editconf19", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/tailscale") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/tailscale", value)
		if (luci.sys.call("cmp -s /tmp/tailscale /etc/config/tailscale") == 1) then
			fs.writefile("/etc/config/tailscale", value)
			luci.sys.call("/etc/init.d/tailscale restart >/dev/null")
		end
		fs.remove("/tmp/tailscale")
	end
end
end

--socat
if nixio.fs.access("/etc/config/socat") then
s:tab("config20", translate("配置端口转发"), translate("本页是配置/etc/config/socat的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config20", Value, "editconf20", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/socat") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/socat", value)
		if (luci.sys.call("cmp -s /tmp/socat /etc/config/socat") == 1) then
			fs.writefile("/etc/config/socat", value)
			luci.sys.call("/etc/init.d/socat restart >/dev/null")
		end
		fs.remove("/tmp/socat")
	end
end
end

--msd_lite
if nixio.fs.access("/etc/config/msd_lite") then
s:tab("config21", translate("配置组播转换"), translate("本页是配置/etc/config/msd_lite的文档内容。应用保存后自动重启生效"))
conf = s:taboption("config21", Value, "editconf21", nil, translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"

function conf.cfgvalue(self, section)
	return fs.readfile("/etc/config/msd_lite") or ""
end

function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/msd_lite", value)
		if (luci.sys.call("cmp -s /tmp/msd_lite /etc/config/msd_lite") == 1) then
			fs.writefile("/etc/config/msd_lite", value)
			luci.sys.call("/etc/init.d/msd_lite restart >/dev/null")
		end
		fs.remove("/tmp/msd_lite")
	end
end
end

return m
