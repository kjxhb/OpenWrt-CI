local common = require "luci.model.cbi.tailscale.tailscale_common"

local _ = translate or luci.i18n.translate

local status_data = common.get_status()
local interface_subnets = common.get_interface_subnets()
local online_exit_nodes = status_data.onlineExitNodes or {}
local subnet_routes = status_data.subnetRoutes or {}

local m, s, o

m = Map("tailscale",
	_("Tailscale"),
	_("Tailscale is a cross-platform and easy to use virtual LAN."))

s = m:section(SimpleSection)
s.template = "tailscale/status_bar"

s = m:section(NamedSection, "settings", "tailscale")
s:tab("basic", _("Basic Settings"))

o = s:taboption("basic", Flag, "enabled", _("Enable"))
o.default = o.disabled
o.rmempty = false

o = s:taboption("basic", DummyValue, "login_status", _("Login Status"))
o:depends({ enabled = "1" })
o.template = "tailscale/login_status"

o = s:taboption("basic", Value, "port", _("Port"),
	_("Set the Tailscale port number."))
o.datatype = "port"
o.default = "41641"
o.rmempty = false

o = s:taboption("basic", Value, "config_path", _("Workdir"),
	_("The working directory contains config files, audit logs, and runtime info."))
o.default = "/etc/tailscale"
o.rmempty = false

o = s:taboption("basic", ListValue, "fw_mode", _("Firewall Mode"))
o:value("iptables", "iptables")
o:value("nftables", "nftables")
o.default = "iptables"
o.rmempty = false

o = s:taboption("basic", Flag, "log_stdout", _("StdOut Log"),
	_("Logging program activities."))
o.default = o.enabled
o.rmempty = false

o = s:taboption("basic", Flag, "log_stderr", _("StdErr Log"),
	_("Logging program errors and exceptions."))
o.default = o.enabled
o.rmempty = false

s:tab("advance", _("Advanced Settings"))

o = s:taboption("advance", Flag, "accept_routes", _("Accept Routes"),
	_("Accept subnet routes that other nodes advertise."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("advance", Value, "hostname", _("Device Name"),
	_("Leave blank to use the device's hostname."))
o.default = ""
o.rmempty = true

o = s:taboption("advance", Flag, "accept_dns", _("Accept DNS"),
	_("Accept DNS configuration from the Tailscale admin console."))
o.default = o.enabled
o.rmempty = false

o = s:taboption("advance", Flag, "advertise_exit_node", _("Exit Node"),
	_("Offer to be an exit node for outbound internet traffic from the Tailscale network."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("advance", ListValue, "exit_node", _("Online Exit Nodes"),
	_("Select an online machine name to use as an exit node."))
if #online_exit_nodes > 0 then
	o.optional = true
	for _, node in ipairs(online_exit_nodes) do
		o:value(node, node)
	end
else
	o:value("", _("No Available Exit Nodes"))
end
o.default = ""
o:depends({ advertise_exit_node = "0" })
o.rmempty = true

o = s:taboption("advance", DynamicList, "advertise_routes", _("Expose Subnets"),
	_("Expose physical network routes into Tailscale, e.g. <code>10.0.0.0/24</code>."))
for _, subnet in ipairs(interface_subnets) do
	o:value(subnet, subnet)
end
o.default = ""
o.rmempty = true

o = s:taboption("advance", Flag, "disable_snat_subnet_routes", _("Site To Site"),
	_("Use site-to-site layer 3 networking to connect subnets on the Tailscale network."))
o.default = o.disabled
o:depends({ accept_routes = "1" })
o.rmempty = false

o = s:taboption("advance", DynamicList, "subnet_routes", _("Subnet Routes"),
	_("Select subnet routes advertised by other nodes in Tailscale network."))
if #subnet_routes > 0 then
	for _, route in ipairs(subnet_routes) do
		o:value(route, route)
	end
else
	o:value("", _("No Available Subnet Routes"))
	o.readonly = true
end
o.default = ""
o:depends({ disable_snat_subnet_routes = "1" })
o.rmempty = true

o = s:taboption("advance", MultiValue, "access", _("Access Control"))
o:value("ts_ac_lan", _("Tailscale access LAN"))
o:value("ts_ac_wan", _("Tailscale access WAN"))
o:value("lan_ac_ts", _("LAN access Tailscale"))
o:value("wan_ac_ts", _("WAN access Tailscale"))
o.default = { "ts_ac_lan", "ts_ac_wan", "lan_ac_ts" }
o.rmempty = true

s:tab("extra", _("Extra Settings"))

o = s:taboption("extra", DynamicList, "flags", _("Additional Flags"),
	string.format(
		_("List of extra flags. Format: --flags=value, e.g. <code>--exit-node=10.0.0.1</code>. <br> %s for enabling settings upon the initiation of Tailscale."),
		'<a href="https://tailscale.com/kb/1241/tailscale-up" target="_blank">' ..
		_("Available flags") .. '</a>'))
o.default = ""
o.rmempty = true

s = m:section(NamedSection, "settings", "tailscale")
s.title = _("Custom Server Settings")
s.description = string.format(
	_("Use %s to deploy a private server."),
	'<a href="https://github.com/juanfont/headscale" target="_blank">headscale</a>')

o = s:option(Value, "login_server", _("Server Address"))
o.default = ""
o.rmempty = true

o = s:option(Value, "authKey", _("Auth Key"))
o.default = ""
o.rmempty = true

return m
