local panelHeader = {
  type = "panel",
  name = "PvP Metrics",
  displayName = "PvP Metrics",
  author = "HoboNavity, Thalothean",
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
		getFunc = function() return PVPMetrics.pvpmetricsdata.settings.bgOverlayEnabled end,
		setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.bgOverlayEnabled = val end,
  },
  [3] = {
		type    = "checkbox",
		name    = "Show Cyrodiil Metrics",
		tooltip = "Show Cyrodiil Metrics",
		default = true,
		getFunc = function() return PVPMetrics.pvpmetricsdata.settings.CryoOverlayEnabled end,
		setFunc = function(val) PVPMetrics.pvpmetricsdata.settings.CryoOverlayEnabled = val end,
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
		type = "editbox",
    name = "Killing blow message",
    tooltip = "Message to display on killing blow, useable variables: ${target} ${player}",
    getFunc = function() return PVPMetrics.pvpmetricsdata.settings.killingblowMsg end,
  	setFunc = function(text) PVPMetrics.pvpmetricsdata.settings.killingblowMsg = text end,
    isMultiline = false,	--boolean
		width = "half",	--or "half" (optional)
		disabled = function() return not PVPMetrics.pvpmetricsdata.settings.killingblowMsgEnabled end,
  },
}

function PVPMetrics.menuSettings()
  local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel("PVPMetricsPanel", panelHeader)
  LAM:RegisterOptionControls("PVPMetricsPanel", panelOptions)
end
