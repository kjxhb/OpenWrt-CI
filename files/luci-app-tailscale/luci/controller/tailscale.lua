module("luci.controller.tailscale", package.seeall)

function index()
    entry({"admin", "services", "tailscale"}, cbi("tailscale"), _("Tailscale"), 50).dependent = true
    entry({"admin", "services", "tailscale", "status"}, template("tailscale_status")) .leaf = true
    entry({"admin", "services", "tailscale", "log"}, template("tailscale_log")).leaf = true
end

-- optional AJAX/JSON status endpoint (not used by server-side templates but kept for future use)
function action_status()
    local http = require "luci.http"
    local util = require "luci.util"

    http.prepare_content("application/json")
    local out = util.exec("/usr/sbin/tailscale status --json 2>/dev/null")
    if not out or out == "" then
        http.write_json({ error = "no output" })
    else
        http.write(out)
    end
end
