--pretranslated: do not change this file
gettext.textdomain('webui-core')
local r = require("web.ui_helper")
local e = ngx
local uci = require("uci").cursor()

local helpers = {}
local seen = {}
uci:foreach("firewall", "zone", function(z)
  if z['.name'] ~= "loopback" and z.helper then
    for _, h in ipairs(z.helper) do
      if not seen[h] then
        seen[h] = true
        helpers[#helpers+1] = h
      end
    end
  end
end)
uci:unload("firewall")
table.sort(helpers)

local n = "/modals/nat-alg-helper-modal.lp"
local link_attrs = ""
if e.ctx.session:hasAccess(n) then
  link_attrs = string.format('class="modal-link" data-toggle="modal" data-remote="%s" data-id="nat-alg-helper-modal"', n)
end

e.print('  <div class="span3">      <div class="smallcard" data-aos="zoom-in" data-aos-anchor-placement="center-bottom" data-aos-easing="ease-in-back">          ')
e.print(r.createCardHeader(T"NAT Helpers", n))
e.print('          <div class="content card_bg" data-bg-text="&#xf0eb;">          <div class="divtable">              ')
if #helpers > 0 then
  e.print('<span class="simple-desc"><i class="fas fa-info-circle" aria-hidden="true"></i>&nbsp;')
  e.print(string.format('<strong %s>%d Helper NAT attivi</strong>', link_attrs, #helpers))
  e.print('</span>')
  e.print('<p class="subinfos">' .. table.concat(helpers, ", ") .. '</p>')
else
  e.print('<span class="simple-desc">' .. T"Nessun helper NAT attivo" .. '</span>')
end
e.print('           </div>           </div>      </div>  </div>')
