local ngx = ngx
local helpers = {}
-- local string = require "string"
local json = require "cjson.safe"

helpers.hostnames = {"ipfs.io", "blog.ipfs.io", "clock.thattommyhall.io"}

local function split_lines(str)
    local lines = {}
    for s in str:gmatch("[^\r\n]+") do
        lines[#lines + 1] = s
    end
    return lines
end

function helpers.api(httpc, path, params, method)
    if method == nil then
        method = "POST"
    end
    local api_root = "http://cluster0:9094"
    local full_url = api_root .. path
    if type(params) == "string" then
        params = {
            arg = params
        }
    end
    local res, err =
        httpc:request_uri(
        full_url,
        {
            method = "POST",
            query = params
        }
    )
    if res then
        local body = res.body
        local table, err = json.decode(body)
        if table then -- It was JSON
            return table, err
        else -- Maybe its JSONL?
            local result = {}
            for _, line in ipairs(split_lines(body)) do
                result[#result + 1] = json.decode(line)
            end
            return result, err
        end
    else
        return res, err
    end
end

-- function helpers.pin_cid(httpc, ipfs_path)
--     ngx.log(ngx.INFO, "Pinning " .. ipfs_path)
-- end

-- function helpers.verify_pins(httpc)
--     return helpers.api(
--         httpc,
--         "/pin/verify",
--         {
--             verbose = true
--         }
--     )
-- end

-- function helpers.get_root_cid(httpc, hostname)
--     local res, err = helpers.api(httpc, "/dns", hostname)
--     if res then
--         return res["Path"], err
--     else
--         return res, err
--     end
-- end

return helpers
