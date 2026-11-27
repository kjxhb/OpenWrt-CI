module("luci.controller.tailscale", package.seeall)

local jsonc = require "luci.jsonc"
local common = require "luci.model.cbi.tailscale.tailscale_common"

function index()
	if not nixio.fs.access("/etc/config/tailscale") then
		return
	end

	local page = entry({"admin", "vpn", "tailscale"},
		cbi("tailscale/setting"),
		_("Tailscale"), 90)
	page.i18n = "tailscale"
	page.dependent = true

	entry({"admin", "vpn", "tailscale", "status"}, call("get_status"))
end

function get_status()
	luci.http.prepare_content("application/json")
	luci.http.write(jsonc.stringify(common.get_status()))
end
