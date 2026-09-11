local dkjson = require("dkjson")
local ngx = ngx

local function readfile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local data = {queries = "-", blocked = "-", percent = "-"}
local content = readfile("/opt/var/run/adguard_card_stats.txt")
if content then
  for k, v in content:gmatch("(%a+)=([%d%.]+)") do
    if k == "QUERIES" then data.queries = v end
    if k == "BLOCKED" then data.blocked = v end
    if k == "PERCENT" then data.percent = v end
  end
end

local out = {}
if dkjson.encode(data, {indent=false, buffer=out}) then
  ngx.say(out)
else
  ngx.say("{}")
end
ngx.exit(ngx.HTTP_OK)
