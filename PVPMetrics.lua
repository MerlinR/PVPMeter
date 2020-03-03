PVPMetrics = {}
PVPMetrics.name = "PVPMetrics"

-- SECTION CORE functionality

-- PVP Metrics class
function PVPMetrics:Initialize()
  self.pvpmetricsdata = ZO_SavedVars:NewCharacterIdSettings("pvpmetricsdata", 1, nil, {})
  
  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED)

  -- NOTE events require function to be linked to, E.G commented out till required.
  -- Common Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_DEAD, self.OnDeath)

  -- UI Change events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_ACTIVATED, self.zoneChange)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, self.UIswitch)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_BANK, self.bankOpen)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_STORE, self.bankOpen)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_TRADING_HOUSE, self.bankOpen)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_GUILD_BANK, self.bankOpen)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_CHATTER_BEGIN, self.bankOpen)

  -- BG Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_MEDAL_AWARDED, self.onPointUpdate)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, self.onScoreUpdate)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_KILL, self.onBgKill)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_STATE_CHANGED, self.onBgStateChange)

  -- Duel Events
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_FINISHED, self.onDuelFinish)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_STARTED, self.onDuelStart)

  self.pvpmetricsdata = PVPMetrics:InitializeProfile()

  PVPMetrics.zoneChange()
  PVPMetrics.displayBGOverlay(false)
  PVPMetrics.restoreBgOverlay()
end


function PVPMetrics.OnAddOnLoaded(event, addonName)
  if addonName == PVPMetrics.name then
    PVPMetrics:Initialize()
  end
end

function PVPMetrics:InitializeProfile()
  if self.pvpmetricsdata.settings ~= nil then
    return self.pvpmetricsdata
  end

  self.pvpmetricsdata.settings = {}

end



-- SECTION BG GUI's

-- Restore BG Overlay, bottom right is default
function PVPMetrics.restoreBgOverlay()
  if PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft ~= nil then
    PVPMetricsBGOverlay:ClearAnchors()
    PVPMetricsBGOverlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft, PVPMetrics.pvpmetricsdata.settings.bgOverlayTop)
  else
    PVPMetricsBGOverlay:ClearAnchors()
    PVPMetricsBGOverlay:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
  end
end

-- Save Position of BG Overlay when moved
function PVPMetrics.OnBGOverlayMoveStop()
  PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft = PVPMetricsBGOverlay:GetLeft()
  PVPMetrics.pvpmetricsdata.settings.bgOverlayTop = PVPMetricsBGOverlay:GetTop()
end

-- Hide or Show BG GUI Overlay
function PVPMetrics.displayBGOverlay(show)
  if ( show ) then
    PVPMetricsBGOverlay:SetHidden(false)
  else
    PVPMetricsBGOverlay:SetHidden(true)
  end
end



-- SECTION BG Functions

function PVPMetrics.onBgKill()

end


function PVPMetrics.onPointUpdate()

end


function PVPMetrics.onScoreUpdate()

end


function PVPMetrics.onBgStateChange()

end



-- SECTION Common Functions

function PVPMetrics.OnDeath()

end


function PVPMetrics.zoneChange()
  -- TODO Finish, update to current zone from defines.lua
  PVPMetrics.zone = 1
end



-- SECTION DEBUGGING Tools

-- Debugging function, /metricsbgov 1 (show bg GUI) /metricsbgov 2 (hide bg GUI)
function DEBUGdisplayBGOverlay(arg)
  if arg == "1" then PVPMetrics.displayBGOverlay(true) else PVPMetrics.displayBGOverlay(false) end
end
SLASH_COMMANDS["/metricsbgov"] = DEBUGdisplayBGOverlay

-- Debugging function, /metricsreset (Reset all settings)
function DEBUGRESET(arg)
  PVPMetrics.pvpmetricsdata.settings = {}
end
SLASH_COMMANDS["/metricsreset"] = DEBUGRESET

-- SECTION MAIN - The initial event to load the Addon
do
    EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED, PVPMetrics.OnAddOnLoaded)
end