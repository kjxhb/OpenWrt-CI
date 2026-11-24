local common = require "luci.model.cbi.tailscale.tailscale_common"

local _ = translate or luci.i18n.translate

local st = common.get_status(true)
local peers = st.peers or {}
local subroutes = common.get_subroutes().routes or {}

local m, s, o

m = Map("tailscale",
	_("Tailscale"),
	_("Tailscale is a mesh VPN solution that makes it easy to connect your devices securely. This configuration page allows you to manage Tailscale settings on your OpenWrt device."))

function m.on_after_commit(self)
	local util = require "luci.util"
	util.exec('/bin/sh -c ' ..
		'"(lua /usr/lib/lua/luci/model/cbi/tailscale/tailscale_common.lua) ' ..
		'</dev/null >/dev/null 2>&1 &"')
end

s = m:section(SimpleSection)
s.template = "tailscale/overview"

s = m:section(NamedSection, "settings", "tailscale", _("Settings"))

s:tab("account", _("Basic Settings"))

o = s:taboption("account", Flag, "enabled", _("Enable"))
o.default = (st.status == 'running') and o.enabled or o.disabled
o.rmempty = false

o = s:taboption("account", Value, "custom_login_url", _("Custom Login Server"),
	_("Optional: Specify a custom control server URL (e.g., a Headscale instance, %s).")
	:format("https://example.com")
	.. "<br>" .. _("Leave blank for default Tailscale control plane."))
o.placeholder = ""
o.rmempty = true

o = s:taboption("account", Value, "custom_login_AuthKey", _("Custom Login Server Auth Key"),
	_("Optional: Specify an authentication key for the custom control server. Leave blank if not required.")
	.. "<br>" .. _("If you are using custom login server but not providing an Auth Key, will redirect to the login page without pre-filling the key."))
o.placeholder = ""
o.rmempty = true

s:tab("general", _("Advanced Settings"))

o = s:taboption("general", ListValue, "fw_mode", _("Firewall Mode"),
	_("Select the firewall backend for Tailscale to use. Requires service restart to take effect."))
o:value("nftables", "nftables")
o:value("iptables", "iptables")
o.default = "nftables"
o.rmempty = false

o = s:taboption("general", Flag, "accept_routes", _("Accept Routes"),
	_("Allow accepting routes announced by other nodes."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "advertise_exit_node", _("Advertise Exit Node"),
	_("Declare this device as an Exit Node."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "exit_node_allow_lan_access", _("Allow LAN Access"),
	_("When using the exit node, access to the local LAN is allowed."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "runwebclient", _("Enable Web Interface"),
	_("Expose a web interface on port 5252 for managing this node over Tailscale."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "nosnat", _("Disable SNAT"),
	_("Disable Source NAT (SNAT) for traffic to advertised routes. Most users should leave this unchecked."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "shields_up", _("Shields Up"),
	_("When enabled, blocks all inbound connections from the Tailscale network."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "ssh", _("Enable Tailscale SSH"),
	_("Allow connecting to this device through the SSH function of Tailscale."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", Flag, "disable_magic_dns", _("Disable MagicDNS"),
	_("Use system DNS instead of MagicDNS."))
o.default = o.disabled
o.rmempty = false

o = s:taboption("general", ListValue, "exit_node", _("Exit Node"),
	_("Select an exit node from the list. If enabled, Allow LAN Access is enabled implicitly."))
o:value("", _("None"))
for _, peer in ipairs(peers) do
	if peer.exit_node_option then
		local primary_ip = peer.ip:gsub("<br>.*$", "")
		local label = peer.hostname ~= "" and
			string.format("%s (%s)", peer.hostname, primary_ip) or primary_ip
		o:value(primary_ip, label)
	end
end
o.default = ""
o.rmempty = true

o = s:taboption("general", DynamicList, "advertise_routes", _("Advertise Routes"),
	_("Advertise subnet routes behind this device. Select from the detected subnets below or enter custom routes (comma-separated)."))
for _, subnet in ipairs(subroutes) do
	o:value(subnet, subnet)
end
o.default = ""
o.rmempty = true
o.template = "tailscale/overview"

o = s:taboption("general", Button, "_setup_firewall", _("Auto Configure Firewall"),
	_("Essential configuration for Subnet Routing (Site-to-Site) and Exit Node features.")
	.. "<br>" .. _("It automatically creates the tailscale interface, sets up firewall zones for LAN <-> Tailscale forwarding,")
	.. "<br>" .. _("and enables Masquerading and MSS Clamping (MTU fix) to ensure stable connections."))
o.inputstyle = "action"

o = s:taboption("general", DummyValue, "_help_title", _("How to enable Site-to-Site?"))
o.rawhtml = true
o.template = "tailscale/overview"
o.value =
	_('1. Select "Accept Routes" (to access remote devices).') .. "<br>" ..
	_('2. In "Advertise Routes", select your local subnet (to allow remote devices to access this LAN).') .. "<br>" ..
	_('3. Click "Auto Configure Firewall" (to allow traffic forwarding).') .. "<br>" ..
	'<strong style="color:#d9534f">' ..
	_('[Important] Log in to the Tailscale admin console and manually enable "Subnet Routes" for this device.') ..
	"</strong>"

s:tab("devices", _("Network Devices"))

o = s:taboption("devices", DummyValue, "_devices_panel", "")
o.rawhtml = true
o.value = '<div id="ts_devices_panel"></div>'

return m
