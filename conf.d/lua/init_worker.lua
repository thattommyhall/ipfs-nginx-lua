-- auto_ssl:init_worker()

local http = require "resty.http"

local helpers = require "helpers"
ngx.log(ngx.INFO, "Loading Lua Worker")

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
    ngx.timer.at(15, refresh_all)
end

-- ngx.timer.every(15, refresh_all)
ngx.timer.at(15, refresh_all)
