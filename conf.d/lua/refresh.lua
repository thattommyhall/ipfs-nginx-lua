local http = require "resty.http"
local json = require "cjson.safe"

local helpers = require "helpers"
local result = {}

local function refresh(httpc, hostname)
    ngx.log(ngx.INFO, "Refreshing for " .. hostname)
    local old_cid = ngx.shared.dnslink:get(hostname)
    local ipfs_path = "/ipns/" .. hostname

    local res, err = helpers.api(httpc, "/pins" .. ipfs_path)
    if res then
        if res["cid"] and res["cid"]["/"] then
            local root_cid = res["cid"]["/"]
            ngx.shared.pins:set(root_cid, true)
            if root_cid ~= old_cid then
                ngx.log(ngx.INFO, "Detected new dnslink of " .. root_cid)
                ngx.shared.dnslink:set(hostname, root_cid)
            end
        end
    else
        ngx.shared.pins:set(ipfs_path, {err = err})
    end
end

local function refresh_all()
    ngx.log(ngx.INFO, "Refreshing")
    local httpc = http.new()
    local hostnames = helpers.hostnames
    for i = 1, #hostnames do
        refresh(httpc, hostnames[i])
    end
end

refresh_all()

ngx.say(json.encode(result))
