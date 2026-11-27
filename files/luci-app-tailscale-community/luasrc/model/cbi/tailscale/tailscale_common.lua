local jsonc = require "luci.jsonc"
local util  = require "luci.util"
local uciM  = require "luci.model.uci"
local nixio = require "nixio"

local M = {}

local TS = "/usr/sbin/tailscale"

local function shell_quote(s)
	if s == nil or s == '' then
		return "''"
	end
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function exec(cmd)
	local p = io.popen(cmd .. " 2>&1; echo __RC=$?")
	if not p then
		return -1, ""
	end
	local content = p:read("*a") or ""
	p:close()
	local rc = tonumber(content:match("__RC=(%d+)")) or -1
	content = content:gsub("\n?__RC=%d+%s*$", "")
	content = content:gsub("%s+$", "")
	return rc, content
end

local function daemon_alive()
	local fh = io.popen('killall -0 tailscaled 2>/dev/null; echo __RC=$?')
	local chk = fh:read('*a') or ''
	fh:close()
	return chk:match('__RC=(%d+)') == '0'
end

function M.get_status(raw_mode)
	local data = {
		status = '',
		version = '',
		TUNMode = '',
		health = '',
		ipv4 = "Not running",
		ipv6 = nil,
		domain_name = '',
		auth_url = nil,
		peers = {}
	}

	if not nixio.fs.access("/usr/sbin/tailscale") and not nixio.fs.access("/usr/bin/tailscale") then
		data.status = 'not_installed'
		return data
	end

	if not daemon_alive() then
		data.status = 'not_running'
		return data
	end

	local code, out = exec(TS .. " status --json")
	if code == 0 and #out > 0 then
		local ok, st = pcall(jsonc.parse, out)
		if ok and type(st) == "table" then
			data.version = st.Version or 'Unknown'
			data.health = st.Health or ''
			data.TUNMode = st.TUN
			if data.TUNMode == nil then data.TUNMode = true end

			local uci = uciM.cursor()
			local enabled = uci:get('tailscale', 'settings', 'enabled')
			local authkey = uci:get('tailscale', 'settings', 'custom_login_AuthKey') or ''
			local auto_login = enabled == '1' and authkey ~= ''

			if st.BackendState == 'Running' then data.status = 'running' end
			if st.BackendState == 'NeedsLogin' then
				data.status = (not raw_mode and auto_login) and 'starting' or 'logout'
			end
			if st.BackendState == 'Starting' or st.BackendState == 'NoState' then
				data.status = 'starting'
			end
			data.auth_url = st.AuthURL

			local ips = st.Self and st.Self.TailscaleIPs
			if type(ips) == 'table' then
				data.ipv4 = ips[1] or 'No IP assigned'
				data.ipv6 = ips[2]
			else
				data.ipv4 = 'No IP assigned'
			end

			data.domain_name = (st.CurrentTailnet and st.CurrentTailnet.Name) or ''

			local peer_map = {}
			if type(st.Peer) == 'table' then
				for _, p in pairs(st.Peer) do
					local ip_list = ''
					if type(p.TailscaleIPs) == 'table' then
						ip_list = table.concat(p.TailscaleIPs, '<br>')
					end

					local hostname = ''
					if type(p.DNSName) == 'string' then
						hostname = p.DNSName:match('^([^.]*)') or ''
					end

					local linkadress = p.CurAddr
					if not linkadress or linkadress == '' then
						linkadress = p.Relay
					end

					peer_map[#peer_map + 1] = {
						ip = ip_list,
						hostname = hostname,
						ostype = p.OS,
						online = p.Online,
						linkadress = linkadress,
						lastseen = p.LastSeen,
						exit_node = p.ExitNode and true or false,
						exit_node_option = p.ExitNodeOption and true or false,
						tx = p.TxBytes or '',
						rx = p.RxBytes or ''
					}
				end
			end
			data.peers = peer_map
		end
	end

	return data
end

local login_action, logout_action, add_network_iface, remove_network_iface

function set_settings(form_data)
	if type(form_data) ~= 'table' or next(form_data) == nil then
		return { error = 'Missing or invalid form_data parameter. Please provide settings data.' }
	end

	local current = M.get_status(true)
	local want_enabled = form_data.enabled == '1'
	local login_url = nil

	if want_enabled and current.status ~= 'running' then
		local res = login_action({
			loginserver = form_data.loginserver or '',
			loginserver_authkey = form_data.loginserver_authkey or ''
		})
		if res.error then return res end
		if res.url then login_url = res.url end
	elseif (not want_enabled) and (current.status == 'running' or current.status == 'logout') then
		local res = logout_action()
		if res.error then return res end
	end

	if M.get_status(true).status == 'running' then
		add_network_iface()
		local args = { 'set' }
		args[#args + 1] = '--accept-routes=' .. tostring(form_data.accept_routes == '1')
		args[#args + 1] = '--advertise-exit-node=' .. tostring(
			form_data.advertise_exit_node == '1' and form_data.exit_node == '')
		if form_data.exit_node == "" then
			args[#args + 1] = '--exit-node-allow-lan-access=' .. tostring(
				form_data.exit_node_allow_lan_access == '1')
		end
		args[#args + 1] = '--ssh=' .. tostring(form_data.ssh == '1')
		args[#args + 1] = '--accept-dns=' .. tostring(form_data.disable_magic_dns ~= '1')
		args[#args + 1] = '--shields-up=' .. tostring(form_data.shields_up == '1')
		args[#args + 1] = '--webclient=' .. tostring(form_data.runwebclient == '1')
		args[#args + 1] = '--snat-subnet-routes=' .. tostring(form_data.nosnat ~= '1')

		local routes = form_data.advertise_routes or ''
		if type(routes) == 'table' then routes = table.concat(routes, ',') end
		routes = routes:gsub('%s', '')
		args[#args + 1] = '--advertise-routes ' .. shell_quote(routes)

		args[#args + 1] = '--exit-node=' .. shell_quote(form_data.exit_node)
		if form_data.exit_node ~= "" then
			args[#args + 1] = '--exit-node-allow-lan-access=true'
		end
		args[#args + 1] = '--hostname ' .. shell_quote(form_data.hostname)

		local cmd = TS .. ' ' .. table.concat(args, ' ')
		local code, out = exec(cmd)
		if code ~= 0 then
			return { error = 'Failed to apply node settings: ' .. out }
		end
	end

	local uci = uciM.cursor()
	for key, val in pairs(form_data) do
		if key ~= 'loginserver' and key ~= 'loginserver_authkey' then
			uci:set('tailscale', 'settings', key, val)
		end
	end
	uci:save('tailscale')
	uci:commit('tailscale')

	if login_url then
		return { success = true, url = login_url }
	end
	return { success = true }
end

function apply_uci_settings()
	local uci = uciM.cursor()
	local keys = {
		'enabled', 'fw_mode', 'accept_routes', 'advertise_exit_node',
		'exit_node_allow_lan_access', 'runwebclient', 'nosnat', 'shields_up',
		'ssh', 'disable_magic_dns', 'exit_node', 'hostname',
		'custom_login_url', 'custom_login_AuthKey', 'advertise_routes'
	}
	local fd = {}
	for _, k in ipairs(keys) do
		fd[k] = uci:get('tailscale', 'settings', k) or ''
	end
	fd.loginserver = fd.custom_login_url
	fd.loginserver_authkey = fd.custom_login_AuthKey
	return set_settings(fd)
end

function remove_network_iface()
	local uci = uciM.cursor()
	uci:load('network')
	uci:load('firewall')

	uci:delete('network', 'tailscale')
	uci:save('network')
	uci:commit('network')

	uci:delete('firewall', 'tszone')
	uci:delete('firewall', 'ts_ac_lan')
	uci:delete('firewall', 'ts_ac_wan')
	uci:save('firewall')
	uci:commit('firewall')
	exec('/etc/init.d/firewall reload')
end

function login_action(form_data)
	if type(form_data) ~= 'table' or next(form_data) == nil then
		return { error = 'Missing or invalid form_data parameter. Please provide login data.' }
	end

	local status = M.get_status(true)
	if status.status == '' or status.status == 'not_running' then
		exec('/etc/init.d/tailscale enable')
		exec('/etc/init.d/tailscale start')
		for _ = 1, 10 do
			util.exec('sleep 2')
			status = M.get_status(true)
			if status.status ~= '' and status.status ~= 'not_running' then break end
		end
	end

	if status.status == 'running' then
		add_network_iface()
		return { authkey = true }
	end

	if status.status == 'starting' then
		for _ = 1, 15 do
			util.exec('sleep 2')
			status = M.get_status(true)
			if status.status == 'running' then
				add_network_iface()
				return { authkey = true }
			elseif status.status == 'logout' then
				break
			end
		end
		if status.status ~= 'logout' then
			return { error = 'Tailscale is starting but did not reach a login state.' }
		end
	end

	if status.status ~= 'logout' then
		return { error = 'Tailscale is already logged in and running.' }
	end

	local loginargs = {}
	local loginserver = (form_data.loginserver or ''):gsub('^%s*(.-)%s*$', '%1')
	local authkey = (form_data.loginserver_authkey or ''):gsub('^%s*(.-)%s*$', '%1')

	if loginserver ~= '' then
		loginargs[#loginargs + 1] = '--login-server ' .. shell_quote(loginserver)
	end
	if authkey ~= '' then
		loginargs[#loginargs + 1] = '--auth-key ' .. shell_quote(authkey)
	end

	local login_cmd = TS .. ' login ' .. table.concat(loginargs, ' ')
	util.exec('/bin/sh -c ' .. shell_quote(login_cmd .. ' </dev/null >/dev/null 2>&1 &'))

	if authkey ~= '' then
		for _ = 1, 15 do
			if M.get_status(true).status == 'running' then
				add_network_iface()
				return { authkey = true }
			end
			util.exec('sleep 2')
		end
		return { error = 'Login with auth key timed out after 30 seconds.' }
	end

	for _ = 1, 15 do
		local _, t_out = exec(TS .. ' status')
		for trline in t_out:gmatch('[^\r\n]+') do
			if trline:find('http', 1, true) then
				for part in trline:gmatch('%S+') do
					if part:find('http', 1, true) then
						return { url = part }
					end
				end
			end
		end
		util.exec('sleep 2')
	end

	return { error = 'Could not retrieve login URL from tailscale command after 30 seconds.' }
end

function logout_action()
	local status = M.get_status(true)

	if status.status == 'running' then
		exec(TS .. ' logout')
	end

	exec('/etc/init.d/tailscale disable')
	exec('/etc/init.d/tailscale stop')
	for _ = 1, 15 do
		util.exec('sleep 1')
		if not daemon_alive() then break end
	end

	remove_network_iface()
	return { success = true }
end

local function uci_subnets()
	local result = {}
	local uci = uciM.cursor()
	local function ip2num(ip)
		local a, b, c, d = ip:match('^(%d+)%.(%d+)%.(%d+)%.(%d+)$')
		if not a then return nil end
		return ((a * 256 + b) * 256 + c) * 256 + d
	end
	local function num2ip(n)
		return string.format('%d.%d.%d.%d',
			math.floor(n / 16777216) % 256,
			math.floor(n / 65536) % 256,
			math.floor(n / 256) % 256,
			n % 256)
	end

	for _, net in ipairs({ 'lan', 'wan' }) do
		local addrs = uci:get_list('network', net, 'ipaddr') or {}
		local masks = uci:get_list('network', net, 'netmask') or {}
		for i, addr in ipairs(addrs) do
			local ipn = ip2num(addr)
			local maskn = ip2num(masks[i] or '255.255.255.255')
			if ipn and maskn then
				local bits = 0
				local m = maskn
				while m > 0 do bits = bits + (m % 2); m = math.floor(m / 2) end
				local block = 2 ^ (32 - bits)
				local network = ipn - (ipn % block)
				result[string.format('%s/%d', num2ip(network), bits)] = true
			end
		end
	end

	local subnets = {}
	for subnet in pairs(result) do subnets[#subnets + 1] = subnet end
	table.sort(subnets)
	return subnets
end

function M.get_subroutes()
	local code, out = exec('ip -j route')
	if code == 0 and #out > 0 then
		local ok, routes = pcall(jsonc.parse, out)
		if ok and type(routes) == 'table' then
			local subnets = {}
			for _, route in ipairs(routes) do
				if type(route) == 'table' and route.dst
					and route.dst ~= 'default'
					and route.scope == 'link'
					and route.dst:find('.', 1, true) then
					subnets[#subnets + 1] = route.dst
				end
			end
			return { routes = subnets }
		end
	end

	return { routes = uci_subnets() }
end

function add_network_iface()
	local uci = uciM.cursor()
	uci:load('network')
	uci:load('firewall')

	if uci:get('network', 'tailscale') == nil then
		local st = M.get_status(true)
		uci:set('network', 'tailscale', 'interface')
		uci:set('network', 'tailscale', 'proto', 'static')
		uci:set('network', 'tailscale', 'ifname', 'tailscale0')
		if st.ipv4 and st.ipv4 ~= 'No IP assigned' and st.ipv4 ~= 'Not running' then
			uci:set('network', 'tailscale', 'ipaddr', st.ipv4)
			uci:set('network', 'tailscale', 'netmask', '255.255.255.255')
		end
		if st.ipv6 then
			uci:set('network', 'tailscale', 'ip6addr', { st.ipv6 .. '/128' })
		end
		uci:save('network')
		uci:commit('network')
		exec('/etc/init.d/network reload')
	end

	if uci:get('firewall', 'tszone') == nil then
		uci:set('firewall', 'tszone', 'zone')
		uci:set('firewall', 'tszone', 'name', 'tailscale')
		uci:set('firewall', 'tszone', 'input', 'ACCEPT')
		uci:set('firewall', 'tszone', 'output', 'ACCEPT')
		uci:set('firewall', 'tszone', 'forward', 'ACCEPT')
		uci:set('firewall', 'tszone', 'masq', '1')
		uci:set('firewall', 'tszone', 'mtu_fix', '1')
		uci:set('firewall', 'tszone', 'network', { 'tailscale' })

		uci:set('firewall', 'ts_ac_lan', 'forwarding')
		uci:set('firewall', 'ts_ac_lan', 'src', 'tailscale')
		uci:set('firewall', 'ts_ac_lan', 'dest', 'lan')

		uci:set('firewall', 'ts_ac_wan', 'forwarding')
		uci:set('firewall', 'ts_ac_wan', 'src', 'tailscale')
		uci:set('firewall', 'ts_ac_wan', 'dest', 'wan')

		uci:save('firewall')
		uci:commit('firewall')
		exec('/etc/init.d/firewall reload')
	end

	return { success = true, message = 'Tailscale firewall/interface configuration applied.' }
end

if type(arg) == "table" and arg[0] and arg[0]:match("tailscale_common.lua$") then
	apply_uci_settings()
	os.exit(0)
end

return M
