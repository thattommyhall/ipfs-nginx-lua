local dnslink = ngx.shared.dnslink
local hostname = ngx.var.host

local existing = dnslink:get(hostname)
if existing then
    ngx.log(ngx.INFO, "Using saved dnslink")
    ngx.var.dnslink = existing
    ngx.var.proxybypass = ""
    return
end
