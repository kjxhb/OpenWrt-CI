local jsonc = require "luci.jsonc"
local util  = require "luci.util"
local fs    = require "nixio.fs"

local M = {}

local function ip2num(ip)
	local a, b, c, d = ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	if not a then
		return nil
	end
	return ((a * 256 + b) * 256 + c) * 256 + d
end

local function mask2cidr(mask)
	local n = ip2num(mask)
	if not n then
		return nil
	end
	local bits = 0
	while n > 0 do
		bits = bits + (n % 2)
		n = math.floor(n / 2)
	end
	return bits
end

local function num2ip(n)
	return string.format("%d.%d.%d.%d",
		math.floor(n / 16777216) % 256,
		math.floor(n / 65536) % 256,
		math.floor(n / 256) % 256,
		n % 256)
end

function M.format_bytes(bytes)
	local units = { "B", "KB", "MB", "GB", "TB", "PB" }
	local value = tonumber(bytes) or 0
	local i = 1
	while value >= 1024 and i < #units do
		value = value / 1024
		i = i + 1
	end
	if i == 1 then
		return string.format("%d %s", value, units[i])
	end
	return string.format("%.2f %s", value, units[i])
end

function M.is_running()
	local ok, res = pcall(util.ubus, "service", "list",
		{ name = "tailscale" })
	if ok and type(res) == "table" then
		local svc = res.tailscale
		if svc and svc.instances and svc.instances.instance1 then
			return svc.instances.instance1.running and true or false
		end
	end
	return false
end

function M.get_status()
	local status = {
		isRunning = false,
		backendState = nil,
		authURL = nil,
		displayName = nil,
		onlineExitNodes = {},
		subnetRoutes = {}
	}

	status.isRunning = M.is_running()
	status.enabled = require("luci.model.uci").cursor():get(
		"tailscale", "settings", "enabled") or "0"

	if not status.isRunning then
		return status
	end

	local out = util.exec("/usr/sbin/tailscale status --json 2>/dev/null")
	local ok, parsed = pcall(jsonc.parse, out)
	local st = ok and parsed or nil
	if not st then
		return status
	end

	if not st.AuthURL and st.BackendState == "NeedsLogin" then
		util.exec("/usr/sbin/tailscale login >/dev/null 2>&1 &")
	end

	status.backendState = st.BackendState
	status.authURL = st.AuthURL

	if st.BackendState == "Running" and st.Self and st.User then
		local user = st.User[string.format("%.0f", st.Self.UserID)]
		if user then
			status.displayName = user.DisplayName
		end
	end

	if st.Peer then
		local exit_nodes, routes = {}, {}
		for _, peer in pairs(st.Peer) do
			if peer.ExitNodeOption and peer.Online then
				exit_nodes[#exit_nodes + 1] = peer.HostName
			end
			if type(peer.PrimaryRoutes) == "table" then
				for _, route in ipairs(peer.PrimaryRoutes) do
					routes[#routes + 1] = route
				end
			end
		end
		status.onlineExitNodes = exit_nodes
		status.subnetRoutes = routes
	end

	return status
end

function M.get_interface_subnets()
	local uci = require "luci.model.uci".cursor()
	local result = {}

	for _, net in ipairs({ "lan", "wan" }) do
		local addrs = uci:get_list("network", net, "ipaddr") or {}
		local masks = uci:get_list("network", net, "netmask") or {}

		for i, addr in ipairs(addrs) do
			local ipn = ip2num(addr)
			local cidr = mask2cidr(masks[i] or "255.255.255.255")
			if ipn and cidr then
				local block = 2 ^ (32 - cidr)
				local network = ipn - (ipn % block)
				result[string.format("%s/%d", num2ip(network), cidr)] = true
			end
		end
	end

	local subnets = {}
	for subnet in pairs(result) do
		subnets[#subnets + 1] = subnet
	end
	table.sort(subnets)
	return subnets
end

local function read_addrs(iface, family)
	local cmd, pattern
	if family == "inet" then
		cmd = "ip -4 addr show dev %s 2>/dev/null"
		pattern = "inet ([%d%.]+)/"
	else
		cmd = "ip -6 addr show dev %s 2>/dev/null"
		pattern = "inet6 ([%x:]+)/"
	end

	local out = util.exec(cmd % iface)
	local first = out:match(pattern)
	if first then
		return first
	end

	local ifout = util.exec("ifconfig %s 2>/dev/null" % iface)
	if family == "inet" then
		return ifout:match("inet addr:([%d%.]+)") or ifout:match("inet ([%d%.]+)")
	else
		return ifout:match("inet6 addr: ([%x:]+)") or ifout:match("inet6 ([%x:]+)")
	end
end

function M.get_iface_info()
	local info = {}

	for name in fs.dir("/sys/class/net") do
		if name:match("^tailscale%d+$") then
			local item = {
				name = name,
				ipv4 = read_addrs(name, "inet"),
				ipv6 = read_addrs(name, "inet6"),
				mtu = (fs.readfile("/sys/class/net/%s/mtu" % name) or ""):match("(%d+)"),
				rxBytes = M.format_bytes((fs.readfile("/sys/class/net/%s/statistics/rx_bytes" % name) or "0"):match("(%d+)")),
				txBytes = M.format_bytes((fs.readfile("/sys/class/net/%s/statistics/tx_bytes" % name) or "0"):match("(%d+)"))
			}
			info[#info + 1] = item
		end
	end

	table.sort(info, function(a, b) return a.name < b.name end)
	return info
end

function M.get_log()
	local raw = util.exec("logread 2>/dev/null | grep tailscale")
	local lines = {}

	for line in raw:gmatch("[^\r\n]+") do
		local tokens = {}
		for token in line:gmatch("%S+") do
			tokens[#tokens + 1] = token
		end

		if #tokens >= 6 then
			local formatted_time = string.format("%s %s - %s", tokens[2], tokens[3], tokens[4])
			local status = tokens[6]
			local new_status, start_index
			if status == "daemon.err" then
				new_status, start_index = "StdErr", 10
			elseif status == "daemon.notice" then
				new_status, start_index = "Info", 11
			else
				new_status, start_index = status, 10
			end

			local messages = {}
			for i = start_index, #tokens do
				messages[#messages + 1] = tokens[i]
			end

			lines[#lines + 1] = string.format("%s [ %s ] - %s",
				formatted_time, new_status, table.concat(messages, " "))
		else
			lines[#lines + 1] = "Log is empty."
		end
	end

	if #lines == 0 then
		lines[1] = "Log is empty."
	end

	return { value = table.concat(lines, "\n"), rows = #lines + 1 }
end

function M.do_logout()
	util.exec("/usr/sbin/tailscale logout >/dev/null 2>&1")
	return { success = true }
end

return M
