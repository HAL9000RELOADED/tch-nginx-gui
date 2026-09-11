--pretranslated: do not change this file
gettext.textdomain('webui-core')
local ui = require('web.ui_helper')

ngx.print('<div class="span3" id="adguardhome-card">  <div class="smallcard" data-aos="zoom-in" data-aos-anchor-placement="center-bottom" data-aos-easing="ease-in-back">    ')
ngx.print(ui.createCardHeader(T"AdGuard Home", nil, nil, nil, nil))
ngx.print('    <div class="content card_bg" data-bg-text="&#xf3ed;">	  <div class="divtable">      ')
ngx.print('<span class="subinfos">' .. T"Query DNS: " .. '<strong data-bind="text: queries"></strong> &middot; ' .. T"Bloccate: " .. '<strong data-bind="text: blocked"></strong> (<strong data-bind="text: percent"></strong>%)</span>')
ngx.print('<p style="text-align:center; margin:8px 0 0 0;"><a class="btn btn-primary" style="display:inline-block; padding:4px 16px; cursor:pointer;" href="http://192.168.1.1:3000" target="_blank" rel="noopener" onclick="window.open(\'http://192.168.1.1:3000\',\'_blank\'); return false;">' .. T"Apri pannello" .. '</a></p>')
ngx.print('	  </div>    </div>  </div></div><script>$(document).ready(function () {	new modgui.createAjaxUpdateCard("adguardhome-card","/ajax/adguard_stats.lua","AdguardCardInterval",10000);})</script>')
