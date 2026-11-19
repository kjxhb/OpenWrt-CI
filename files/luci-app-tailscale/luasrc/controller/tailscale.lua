-- SPDX-License-Identifier: GPL-3.0-only
--
-- Copyright (C) 2024 asvow
-- LuCI controller for Tailscale (OpenWrt 18.06 / Lua LuCI)

module("luci.controller.tailscale", package.seeall)

local jsonc = require "luci.jsonc"
local common = require "luci.model.cbi.tailscale.tailscale_common"

function index()
	if not nixio.fs.access("/etc/config/tailscale") then
		return
	end

	local page = entry({"admin", "vpn", "tailscale"},
		alias("admin", "vpn", "tailscale", "setting"),
		_("Tailscale"), 90)
	page.i18n = "tailscale"
	page.dependent = true

	entry({"admin", "vpn", "tailscale", "setting"},
		cbi("tailscale/setting"), _("Global Settings"), 10)

	entry({"admin", "vpn", "tailscale", "interface"},
		template("tailscale/interface"), _("Interface Info"), 20)

	entry({"admin", "vpn", "tailscale", "log"},
		template("tailscale/log"), _("Logs"), 30)

	entry({"admin", "vpn", "tailscale", "status"}, call("get_status"))
	entry({"admin", "vpn", "tailscale", "proc"}, call("get_proc"))
	entry({"admin", "vpn", "tailscale", "iface"}, call("get_iface"))
	entry({"admin", "vpn", "tailscale", "logdata"}, call("get_log"))
	entry({"admin", "vpn", "tailscale", "logout"}, call("do_logout"))
end

local function reply(data)
	luci.http.prepare_content("application/json")
	luci.http.write(jsonc.stringify(data))
end

function get_status()
	reply(common.get_status())
end

function get_proc()
	reply({ running = common.is_running() })
end

function get_iface()
	reply(common.get_iface_info())
end

function get_log()
	reply(common.get_log())
end

function do_logout()
	reply(common.do_logout())
end
