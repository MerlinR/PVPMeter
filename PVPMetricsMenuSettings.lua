local panelHeader = {
  type = "panel",
  name = "PvP Metrics",
  displayName = "PvP Metrics",
  author = "Hobo Navity, Thalothean",
  version = "1.1",
  slashCommand = "/pvpmetrics",
  registerForRefresh = true,
}

local panelOptions = {
  
  [1] = {
    type = "header",
    name = "PVP Metrics",
  },
  [2] = {
    type    = "checkbox",
    name    = "Show BG Metrics",
    tooltip = "Show BG Metrics",
    default = true,
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.OverlayEnabledBG end,
    setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.OverlayEnabledBG = val end,
  },
  [3] = {
    type    = "checkbox",
    name    = "Show Cyrodiil Metrics",
    tooltip = "Show Cyrodiil Metrics",
    default = true,
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.OverlayEnabledCryo end,
    setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.OverlayEnabledCryo = val end,
  },
  [4] = {
    type    = "dropdown",
    name    = "Killing blow sound",
    default = 1,
    tooltip = "If killing blow play a sound",
    choices = soundOptions,
    getFunc = function() return soundOptions[PVPMetrics.pvpmetricsdata.settings.killSound] end,
    setFunc = function(val)
      for i=1,#soundOptions do
        if (soundOptions[i] == val) then
          PVPMetrics.pvpmetricsdata.settings.killSound = i
        end
      end
      if (PVPMetrics.pvpmetricsdata.settings.killSound > 1) then
        PlaySound(killSounds[PVPMetrics.pvpmetricsdata.settings.killSound])
      end
    end,
  },
  [5] = {
    type    = "checkbox",
    name    = "Killing blow messages",
    tooltip = "Pops message on screen when getting a killing blow",
    default = false,
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.killingblowMsgEnabled end,
    setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.killingblowMsgEnabled = val end,
  },
  [6] = {
    type    = "editbox",
    name    = "Killing blow message",
    tooltip = "Message to display on killing blow, useable variables: ${target} ${player}",
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.killingblowMsg end,
    setFunc = function(text) PVPMetrics.pvpmetricsdata.settings.killingblowMsg = text end,
    isMultiline = false,	--boolean
    width = "half",	--or "half" (optional)
    disabled = function() return not PVPMetrics.pvpmetricsdata.settings.killingblowMsgEnabled end,
  },
  [7] = {
    type    = "checkbox",
    name    = "Auto equip guild tabard in PVP",
    tooltip = "Equips yor guild tabard in PVP, auto unequips when outside",
    default = false,
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.equipTabardEnabled end,
    setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.equipTabardEnabled = val end,
  },
  [8] = {
    type    = "dropdown",
    name    = "Tabard to Equip",
    default = 1,
    tooltip = "List of tabards in Inventory that can be equiped",
    choices = tabardOptions,
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.equipTabard end,
    setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.equipTabard = val
    end,
    disabled = function() return not PVPMetrics.pvpmetricsdata.settings.equipTabardEnabled end,
  },
  [9] = {
    type    = "button",
    name    = "Refresh tabard list",
    tooltip = "List of tabards in Inventory is refreshed, used it just got tabard",
    func = function(val) PVPMetrics.getTabardList() end,
    disabled = function() return not PVPMetrics.pvpmetricsdata.settings.equipTabardEnabled end,
  },
}

function PVPMetrics.menuSettings()
  local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel("PVPMetricsPanel", panelHeader)
  LAM:RegisterOptionControls("PVPMetricsPanel", panelOptions)
end
