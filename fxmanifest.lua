--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
description 'DokusCore Banking System - http://DokusCore.com'
author 'DevDokus'
fx_version "adamant"
games {"rdr3"}
version '0.1.0 BETA'
dependencies { 'DokusCore' }
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
client_scripts { '[ Core ]/[ Client ]/*.lua' }
shared_script {
  'Config.lua',
  '@DokusCore/Config.lua',
  '@DokusCore/[ Core ]/[ System ]/Callbacks.lua',
  '@DokusCore/[ Core ]/[ Server ]/[ Data ]/DBTables.lua',
  '@DokusCore/[ Core ]/[ System ]/Shared.lua'
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
ui_page "UI/hud.html"
files {
  'UI/hud.html',
  'UI/data/css/style.css',
  'UI/data/fonts/AncientAd.ttf',
  'UI/data/fonts/Cherolina.ttf',
  'UI/data/fonts/HapnaSlabSerif-DemiBold.ttf',
  'UI/data/fonts/RDRCatalogueBold-Bold.ttf',
  'UI/data/fonts/RDRGothica-Regular.ttf',
  'UI/data/fonts/RDRLino-Regular.ttf',
  'UI/data/fonts/rdrlino-regular-webfont.woff',
  'UI/data/fonts/rdrlino-regular-webfont.woff2',
  'UI/data/fonts/Redemption.ttf',
  'UI/data/fonts/WWI.ttf',
  'UI/data/js/progressbar.js',
  'UI/data/js/progressbar.min.js',
  'UI/data/js/progressbar.min.js.map',
  'UI/data/background.png',
  'UI/hud.html',
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
