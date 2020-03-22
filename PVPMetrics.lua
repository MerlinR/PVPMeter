PVPMetrics = {}
PVPMetrics.name = "PVPMetrics"


function PVPMetrics.InitializeProfile()
  if PVPMetrics.pvpmetricsdata.settings == nil then
    PVPMetrics.pvpmetricsdata = liveDefaults
    PVPMetrics.pvpmetricsdata.settings = settingsDefault
  end
end


-- SECTION BG GUI's

-- Restore BG Overlay, bottom right is default
function PVPMetrics.restoreBgOverlayPosition()
  if PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft ~= nil then
    PVPBGOverlay:ClearAnchors()
    PVPBGOverlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft, PVPMetrics.pvpmetricsdata.settings.bgOverlayTop)
  else
    PVPBGOverlay:ClearAnchors()
    PVPBGOverlay:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
  end
end

-- Save Position of BG Overlay when moved
function PVPMetrics.OnBGOverlayMoveStop()
  PVPMetrics.pvpmetricsdata.settings.bgOverlayLeft = PVPBGOverlay:GetLeft()
  PVPMetrics.pvpmetricsdata.settings.bgOverlayTop = PVPBGOverlay:GetTop()
end

-- Hide or Show BG GUI Overlay
function PVPMetrics.displayBGOverlay(show)
  if ( show )then
    PVPBGOverlay:SetHidden(false)
  else
    PVPBGOverlay:SetHidden(true)
  end
end

-- Update BG GUI text
function PVPMetrics.updateBGOverlayText()
  PVPBGOverlayKill:SetText(PVPMetrics.live.kills)
  PVPBGOverlayAssist:SetText(PVPMetrics.live.assists)
  PVPBGOverlayDeath:SetText(PVPMetrics.live.deaths)
  PVPBGOverlayScore:SetText(PVPMetrics.live.bgScore)
end

-- Set BG GUI Colors
function PVPMetrics.updateBgColors()
  local alliance = GetUnitBattlegroundAlliance("player")

  -- setColor(R,G,B)
  if ( alliance == BATTLEGROUND_ALLIANCE_FIRE_DRAKES ) then
		PVPBGOverlayIconControlIcon:SetColor(0.85,0.4,00)
  elseif ( alliance == BATTLEGROUND_ALLIANCE_PIT_DAEMONS ) then
		PVPBGOverlayIconControlIcon:SetColor(0.36,0.6,0.0)
  elseif ( alliance == BATTLEGROUND_ALLIANCE_STORM_LORDS ) then
		PVPBGOverlayIconControlIcon:SetColor(0.5,0.3,0.6)
  end

  PVPBGOverlayIconControlIcon:SetTexture( GetBattlegroundTeamIcon(alliance))
end


-- When state changes to end or postgame, hide
-- TODO Store results for review after
function PVPMetrics.onBgStateChange(eventCode, previousState, currentState)
  -- Hides BG GUI during end of match screen
  if ( currentState == BATTLEGROUND_STATE_FINISHED or currentState == BATTLEGROUND_STATE_POSTGAME) then
    PVPMetrics.displayBGOverlay(false)
  end
end

-- SECTION BG Functions

-- When entering a BG
function PVPMetrics.enteredBG()
  PVPMetrics.resetLiveStats()
  PVPMetrics.restoreBgOverlayPosition()
  PVPMetrics.updateBGOverlayText()
  PVPMetrics.updateBgColors()
  PVPMetrics.displayBGOverlay(true)
end

-- BG scoreboard update
function PVPMetrics.onScoreUpdate()
  --GetCurrentBattlegroundScore(GetUnitBattlegroundAlliance("player"))
  local playerIndx = GetScoreboardPlayerEntryIndex()
  PVPMetrics.live.kills =   GetScoreboardEntryScoreByType(playerIndx, SCORE_TRACKER_TYPE_KILL)
  PVPMetrics.live.assists = GetScoreboardEntryScoreByType(playerIndx, SCORE_TRACKER_TYPE_ASSISTS)
  PVPMetrics.live.deaths =  GetScoreboardEntryScoreByType(playerIndx, SCORE_TRACKER_TYPE_DEATH)
  PVPMetrics.live.bgScore = GetScoreboardEntryScoreByType(playerIndx, SCORE_TRACKER_TYPE_SCORE)
  PVPMetrics.updateBGOverlayText()
end

-- Kills or assists(not always correct assists)
-- Could pop up the name of killer so we know what bastard to chase after "NoobKilla69 killed ya bitch"
function PVPMetrics.onBgKill(eventCode, killedPlayerCharacterName, killedPlayerDisplayName,
                            killedPlayerBattlegroundAlliance, killingPlayerCharacterName, killingPlayerDisplayName,
                            killingPlayerBattlegroundAlliance, battlegroundKillType)


end


-- When earning medals
function PVPMetrics.onBGMedal(eventCode, medalId, name, iconFilename, value)

end


-- SECTION CYRO Functions

-- When entering a Cyro
function PVPMetrics.enteredCyro()
  --PVPMetrics.resetLiveStats()
  --PVPMetrics.restoreCyroOverlayPosition()
  --PVPMetrics.updateCyroOverlayText()
  --PVPMetrics.displayCyroOverlay(true)
end


-- SECTION Normal world Functions

function PVPMetrics.noPVPZone()
  PVPMetrics.displayBGOverlay(false)
end

-- SECTION Common Functions

function PVPMetrics.onDeath()

end

function PVPMetrics.interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function PVPMetrics.onKill(source, killed)
  if (PVPMetrics.pvpmetricsdata.settings.killSound > 1) then
    PlaySound(killSounds[PVPMetrics.pvpmetricsdata.settings.killSound])
  end
  if PVPMetrics.pvpmetricsdata.settings.killingblowMsgEnabled then
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.ABILITY_NOT_READY)
    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
    params:SetText(PVPMetrics.interp(PVPMetrics.pvpmetricsdata.settings.killingblowMsg, {player = source, target = killed}))
    --params:SetIconData("art/icons/ability_warden_018_c.dds", "art/icons/ability_warden_018_c.dds")
    -- Icons, Background
    params:MarkShowImmediately()
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    -- https://www.esoui.com/forums/showthread.php?t=7038
  end
end


function PVPMetrics.combatEvent(eventCode, actionResult, isError, abilityName, abilityGraphic,
                                abilityActionSlotType, sourceName, sourceType, targetName, targetType,
                                hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if targetType == COMBAT_UNIT_TYPE_OTHER  and actionResult == ACTION_RESULT_KILLING_BLOW and
    sourceType == COMBAT_UNIT_TYPE_PLAYER  and SplitString("^", sourceName) == GetUnitName("player") then
    PVPMetrics.onKill(GetUnitName("player"), SplitString("^", targetName))
  end
end


function PVPMetrics.resetLiveStats()
  PVPMetrics.live = nil
  PVPMetrics.live = liveDefaults
end

function PVPMetrics.onZoneChange()
  -- TODO Finish up instances, remove debugging prints
  if PVPMetrics.live.zone ~= "BG" and IsActiveWorldBattleground() then
    PVPMetrics.live.zone = "BG"
    if ( PVPMetrics.pvpmetricsdata.settings.bgOverlayEnabled ) then
      PVPMetrics.enteredBG()
    end
  elseif PVPMetrics.live.zone ~= "CYRO" and (IsPlayerInAvAWorld() or IsInImperialCity()) then
    PVPMetrics.live.zone = "CYRO"
    if ( PVPMetrics.pvpmetricsdata.settings.bgOverlayEnabled ) then
      PVPMetrics.enteredCyro()
    end
  elseif IsActiveWorldBattleground() == false and IsPlayerInAvAWorld() == false and IsInImperialCity() == false then
    PVPMetrics.noPVPZone()
    PVPMetrics.live.zone = "NORM"
  end
end



-- SECTION DEBUGGING Commands

-- Debugging function, /metricsbgov 1 (show bg GUI) /metricsbgov 2 (hide bg GUI)
function DEBUGdisplayBGOverlay(arg)
  if arg == "1" then PVPMetrics.displayBGOverlay(true) else PVPMetrics.displayBGOverlay(false) end
end
SLASH_COMMANDS["/metricsbgov"] = DEBUGdisplayBGOverlay

-- Debugging function, /metricsreset (Reset all settings)
function DEBUGRESET(arg)
  PVPMetrics.pvpmetricsdata.settings = settingsDefault
end
SLASH_COMMANDS["/metricsreset"] = DEBUGRESET


-- Print all live data
function DEBUGREPRINT(arg)
  d(PVPMetrics.live)
  d(PVPMetrics.pvpmetricsdata)
  d(PVPMetrics.pvpmetricsdata.settings)
end
SLASH_COMMANDS["/metricsdebugprint"] = DEBUGREPRINT


-- Debugging function, /metricsbgov 1 (show bg GUI) /metricsbgov 2 (hide bg GUI)
function DEBUGSOUNDTEST(arg)
  PlaySound(arg)
  d(arg)
end
SLASH_COMMANDS["/playsound"] = DEBUGSOUNDTEST

-- Print all live data
function DEBUGREIMG(arg)
  killingBlowOverlay:SetHidden(false)
  if arg == "hide" then
    killingBlowOverlay:SetHidden(true)
  end
  killingBlowOverlayIcon:SetTexture(arg) 
end
SLASH_COMMANDS["/metricsimg"] = DEBUGREIMG

-- Print all live data
function DEBUGKB(arg)
  PVPMetrics.onKill("Hobo", "Thalo")
end
SLASH_COMMANDS["/metrickb"] = DEBUGKB

-- SECTION CORE functionality

-- PVP Metrics class
function PVPMetrics:Initialize()
  self.pvpmetricsdata = ZO_SavedVars:NewCharacterIdSettings("pvpmetricsdata", 1, nil, {})
  
  -- Generate menu options
  PVPMetrics.menuSettings()
  
  -- Set or use Saved variables
  PVPMetrics.InitializeProfile()

  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED)

  -- NOTE events require function to be linked to, E.G commented out till required.
  -- Common Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_DEAD, self.onDeath)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_COMBAT_EVENT, self.combatEvent)

  -- UI Change events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_PLAYER_ACTIVATED, self.onZoneChange)

  -- BG Events
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, self.onScoreUpdate)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_KILL, self.onBgKill)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_MEDAL_AWARDED, self.onBGMedal)
  EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_BATTLEGROUND_STATE_CHANGED, self.onBgStateChange)

  -- Duel Events
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_FINISHED, self.onDuelFinish)
  --EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_DUEL_STARTED, self.onDuelStart)

  -- Live variables
  self.live = liveDefaults

  PVPMetrics.onZoneChange()
end


function PVPMetrics.OnAddOnLoaded(event, addonName)
  if addonName == PVPMetrics.name then
    PVPMetrics:Initialize()
  end
end



-- SECTION MAIN - The initial event to load the Addon
do
    EVENT_MANAGER:RegisterForEvent(PVPMetrics.name, EVENT_ADD_ON_LOADED, PVPMetrics.OnAddOnLoaded)
end