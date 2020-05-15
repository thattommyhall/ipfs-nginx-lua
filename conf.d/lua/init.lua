require "cjson"
require "resty.http"
require "resty.lock"
-- auto_ssl = (require "resty.auto-ssl").new()

ngx.log(ngx.INFO, "Loading Lua")

-- Define a function to determine which SNI domains to automatically handle
-- and register new certificates for. Defaults to not allowing any domains,
-- so this must be configured.
-- auto_ssl:set(
--     "allow_domain",
--     function(domain)
--         return true
--     end
-- )

-- auto_ssl:init()
