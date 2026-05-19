-- LuCI CBI for Tailscale configuration (OpenWrt 18.06 / LuCI 0.12 compatible)
local m = Map("tailscale", "Tailscale")

m.description = "Manage Tailscale settings"

s = m:section(TypedSection, "settings", "Settings")
s.anonymous = true

enabled = s:option(Flag, "enabled", "Enable")
enabled.default = 0

device_name = s:option(Value, "device_name", "Device Name")
device_name.optional = true

accept_dns = s:option(Flag, "accept_dns", "Accept DNS")
accept_dns.optional = true
accept_dns.default = 0

accept_routes = s:option(Flag, "accept_routes", "Accept Routes")
accept_routes.optional = true
accept_routes.default = 0

return m
