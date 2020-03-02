PVPMetrics = {}
PVPMetrics.name = "PVPMetrics"

-- PVP Metrics class
function PVPMetrics:Initialize()
  PVPMetrics.MetricsData = ZO_SavedVars:NewCharacterIdSettings("pvpmetricsdata", 1, nil, {})
  
  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED)

  -- Common Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_DEAD, self.OnDeath)

  -- UI Change events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, self.UIswitch)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_ACTIVATED, self.zoneChange)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_BANK, self.bankOpen)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_STORE, self.bankOpen)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_TRADING_HOUSE, self.bankOpen)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_OPEN_GUILD_BANK, self.bankOpen)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_CHATTER_BEGIN, self.bankOpen)

  -- BG Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_MEDAL_AWARDED, self.onPointUpdate)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, self.onScoreUpdate)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_KILL, self.onBgKill)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_STATE_CHANGED, self.onBgStateChange)

  -- Duel Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_FINISHED, self.onDuelFinish)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_STARTED, self.onDuelStart)
end


function PVPMetrics:OnAddOnLoaded(event, addonName)
  if addonName == PVPMetrics.name then
    PVPMetrics.Initialize()
  end
end


function PVPMetrics.OnBGOverlayMoveStop()
  LabelKillBG:SetText(PVPMetricsBGOverlay:GetLeft())
  LabelDeathBG:SetText(PVPMetricsBGOverlay:GetTop())

  -- This is failing due to NIL "PVPMetrics.MetricsData.left", unsure why
  --PVPMetrics.MetricsData.left = PVPMetricsBGOverlay:GetLeft()
end


function PVPMetrics.displayBGOverlay(show)
  if ( show ) then
    PVPMetricsBGOverlay:SetHidden(false)
  else
    PVPMetricsBGOverlay:SetHidden(true)
  end
end


-- Debugging function, /bgov 1 (show bg GUI) /bgov 2 (hide bg GUI)
function DEBUGdisplayBGOverlay(arg)
  if arg == "1" then PVPMetrics.displayBGOverlay(true) else PVPMetrics.displayBGOverlay(false) end
end
SLASH_COMMANDS["/bgov"] = DEBUGdisplayBGOverlay


-- The initial event to load the Addon
do
    EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED, PVPMetrics.OnAddOnLoaded)
end