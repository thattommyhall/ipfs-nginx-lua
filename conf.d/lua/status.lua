local ngx = ngx
local json = require "cjson.safe"
local http = require "resty.http"
local helpers = require "helpers"
local httpc = http.new()

local hostname = ngx.var.host
local result = {}
result["hostname"] = hostname
result["dnslink"] = ngx.shared.dnslink:get(hostname)
result["dnslinkvar"] = ngx.var.dnslink
result["pins"] = {}

for _, ipfs_path in ipairs(ngx.shared.pins:get_keys()) do
    local status = ngx.shared.pins:get(ipfs_path)
    result["pins"][ipfs_path] = status
end

-- local res, err = helpers.api(httpc, "/bootstrap/list")
-- if res then
--     result["bootstrappers"] = {}

--     local addrs = res["Peers"]
--     for _, addr in ipairs(addrs) do
--         res, err =
--             helpers.api(
--             httpc,
--             "/ping",
--             {
--                 arg = addr,
--                 count = 1
--             }
--         )
--         if res then
--             result["bootstrappers"][addr] = res
--         else
--             result["bootstrappers"][addr] = false
--         end
--     end
-- end

-- local res, err = helpers.verify_pins(httpc)
-- if res then
--     result["verify_pins"] = res
-- else
--     ngx.log(ngx.ERR, err)
-- end

ngx.say(json.encode(result))
