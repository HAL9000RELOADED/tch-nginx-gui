--pretranslated: do not change this file
gettext.textdomain('webui-core')
local a = require("web.ui_helper")
local dm = require("datamodel")
local e = ngx
local u = string.untaint

if e.req.get_method() == "POST" then
  e.req.read_body()
  local args = e.req.get_post_args()
  e.ctx.session:checkCSRFtoken(args.CSRFtoken)

  local rows = dm.get("uci.firewall_helpers.helper.") or {}
  local byidx = {}
  for _, v in ipairs(rows) do
    byidx[v.path] = byidx[v.path] or {}
    byidx[v.path][v.param] = u(v.value)
  end
  for path, row in pairs(byidx) do
    local wanted = args["helper_" .. row.name] and "1" or "0"
    if wanted ~= row.enable then
      dm.set(path .. "enable", wanted)
    end
  end
  dm.apply()

  e.say('{"result":"ok"}')
  e.exit(e.HTTP_OK)
end

local rows = dm.get("uci.firewall_helpers.helper.") or {}
local byidx = {}
local order = {}
for _, v in ipairs(rows) do
  if not byidx[v.path] then
    byidx[v.path] = {}
    order[#order+1] = v.path
  end
  byidx[v.path][v.param] = u(v.value)
end
table.sort(order, function(x, y) return byidx[x].name:lower() < byidx[y].name:lower() end)

e.print(a.createHeader(T"NAT Helpers (ALG's)", false, false))
e.print('<div class="modal-body update"><form id="nathelperform" class="form-horizontal">')
e.print('<fieldset><table class="table table-striped"><thead><tr><th>' .. T"Enable" .. '</th><th>' .. T"Name" .. '</th><th>' .. T"Dest Port" .. '</th><th>' .. T"Protocol" .. '</th></tr></thead><tbody>')
for _, path in ipairs(order) do
  local row = byidx[path]
  local checked = row.enable == "1" and 'checked="checked"' or ''
  e.print('<tr><td><input type="checkbox" name="helper_' .. row.name .. '" ' .. checked .. '></td><td>' .. row.name:upper() .. '</td><td>' .. row.port .. '</td><td>' .. row.proto:upper() .. '</td></tr>')
end
e.print('</tbody></table></fieldset>')
e.print('</form></div>')
e.print('<div class="modal-footer"><span id="nathelper-msg" style="margin-right:10px;"></span><button id="nathelper-save" type="button" class="btn btn-primary">' .. T"Save" .. '</button></div>')
e.print('<script>$(document).ready(function(){$("#nathelper-save").on("click",function(){var csrf=$(\'meta[name=CSRFtoken]\').attr("content");var data=$("#nathelperform").serialize()+"&CSRFtoken="+encodeURIComponent(csrf);$.post("/modals/nat-alg-helper-modal.lp",data).done(function(){$("#nathelper-msg").text("' .. T"Saved." .. '").css("color","#1e741e");}).fail(function(){$("#nathelper-msg").text("' .. T"Error." .. '").css("color","red");});});});</script>')
