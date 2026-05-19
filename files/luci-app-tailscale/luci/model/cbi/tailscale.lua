-- LuCI CBI for Tailscale configuration (OpenWrt 18.06 / LuCI 0.12 compatible)
local m = Map("tailscale", "Tailscale")
m.description = "Manage Tailscale settings"

s = m:section(TypedSection, "settings", "Settings")
s.anonymous = true

enabled = s:option(Flag, "enabled", "Enable")
enabled.default = 0

port = s:option(Value, "port", "Port")
port.datatype = "port"
port.optional = true
port.default = "41641"

config_path = s:option(Value, "config_path", "Config path")
config_path.optional = true
config_path.default = "/etc/tailscale"

fw_mode = s:option(ListValue, "fw_mode", "Firewall mode")
fw_mode:value("nftables", "nftables")
fw_mode:value("iptables", "iptables")
fw_mode.default = "iptables"

log_stdout = s:option(Flag, "log_stdout", "Log to stdout")
log_stdout.default = 1
log_stdout.optional = true

log_stderr = s:option(Flag, "log_stderr", "Log to stderr")
log_stderr.default = 1
log_stderr.optional = true

hostname = s:option(Value, "hostname", "Device name")
hostname.optional = true

accept_dns = s:option(Flag, "accept_dns", "Accept DNS")
accept_dns.optional = true
accept_dns.default = 1

accept_routes = s:option(Flag, "accept_routes", "Accept routes")
accept_routes.optional = true
accept_routes.default = 0

advertise_exit_node = s:option(Flag, "advertise_exit_node", "Advertise as exit node")
advertise_exit_node.optional = true
advertise_exit_node.default = 0

exit_node = s:option(Value, "exit_node", "Exit node")
exit_node.optional = true

advertise_routes = s:option(Value, "advertise_routes", "Advertise routes (space-separated)")
advertise_routes.optional = true

disable_snat_subnet_routes = s:option(Flag, "disable_snat_subnet_routes", "Disable SNAT for subnet routes")
disable_snat_subnet_routes.optional = true
disable_snat_subnet_routes.default = 0

subnet_routes = s:option(Value, "subnet_routes", "Subnet routes (space-separated)")
subnet_routes.optional = true

access = s:option(Value, "access", "Firewall access lists (comma-separated)")
access.optional = true

flags = s:option(Value, "flags", "Extra flags")
flags.optional = true

login_server = s:option(Value, "login_server", "Login server")
login_server.optional = true

authkey = s:option(Value, "authkey", "Auth key")
authkey.optional = true
authkey.password = true

return m
